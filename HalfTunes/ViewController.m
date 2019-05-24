//
//  ViewController.m
//  HalfTunes
//
//  Created by LeeSen on 2019/5/24.
//  Copyright © 2019 LeeSen. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "TrackCell.h"
#import "TrackModel.h"
#import "Download.h"
#import <MediaPlayer/MediaPlayer.h>

/**
 TODO
 1. 在文件没有下载完成之前退出,再次登录之后,仍需要重新下载该文件;
 2. 在开始下载之后,如果中途暂停会导致无法暂停的问题出现
 3. 没有处理数据为空和错误抛出机制
 */

@interface ViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, TrackCellDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSMutableDictionary *activeDownload;
@property (nonatomic, strong) NSURLSession *defaultSession;
@property (nonatomic, strong) NSURLSession *downloadSession;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (weak, nonatomic) IBOutlet UITableView *songTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSProgress *progress;

@end

@implementation ViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.songTableView.tableFooterView = [UIView new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Target Methods
- (void)eventTapRecognizerResponse
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self eventTapRecognizerResponse];
    if (![searchBar.text isEqualToString:@""]) {
        if (self.dataTask) {
            [self.dataTask cancel];
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSString *searchItem = [searchBar.text stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?media=music&entity=song&term=%@",searchItem]];
        self.dataTask = [self.defaultSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
            if (error) {
                NSLog(@"==== %@ ====", error);
            } else {
                [self updateSearchResult:data];
            }
        }];
        [self.dataTask resume];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackCell" forIndexPath:indexPath];
    cell.delegate = self;
    TrackModel *track = self.searchResults[indexPath.row];
    cell.titleLb.text = track.name;
    cell.artistLb.text = track.artist;
    
    BOOL isShowDownloadControls = NO;
    Download *download = self.activeDownload[track.previewUrl];
    if (download) {
        isShowDownloadControls = YES;
        cell.progressView.progress = download.progress;
        cell.progesssLb.text = download.fileSizeText;
        NSString *pauseTitle = download.isDownloading ? @"暂停" : @"继续";
        [cell.pauseBtn setTitle:pauseTitle forState:UIControlStateNormal];
    }
    cell.progressView.hidden = !isShowDownloadControls;
    cell.progesssLb.hidden = !isShowDownloadControls;
    
    BOOL downloaded = [self localFileExistsForTrack:track];
    cell.selectionStyle = downloaded ? UITableViewCellSelectionStyleGray : UITableViewCellAccessoryNone;
    cell.downloadBtn.hidden = downloaded || isShowDownloadControls;
    cell.pauseBtn.hidden = !isShowDownloadControls;
    cell.cancelBtn.hidden = !isShowDownloadControls;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - TrackCellDelegate
- (void)pauseTapped:(TrackCell *)cell
{
    NSIndexPath *indexPath = [self.songTableView indexPathForCell:cell];
    TrackModel *track = self.searchResults[indexPath.row];
    [self pauseDownload:track];
    [self.songTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)resumeTapped:(TrackCell *)cell
{
    NSIndexPath *indexPath = [self.songTableView indexPathForCell:cell];
    TrackModel *track = self.searchResults[indexPath.row];
    [self resumeDownload:track];
    [self.songTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)cancelTapped:(TrackCell *)cell
{
    NSIndexPath *indexPath = [self.songTableView indexPathForCell:cell];
    TrackModel *track = self.searchResults[indexPath.row];
    [self cancelDownload:track];
    [self.songTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)downloadTapped:(TrackCell *)cell
{
    NSIndexPath *indexPath = [self.songTableView indexPathForCell:cell];
    TrackModel *track = self.searchResults[indexPath.row];
    [self startDownload:track];
    [self.songTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (appDelegate.backgroundSessionCompletionHandler) {
            appDelegate.backgroundSessionCompletionHandler();
            appDelegate.backgroundSessionCompletionHandler = nil;
        }
    });
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *originURL = downloadTask.originalRequest.URL.absoluteString;
    NSURL *destinationURL = [self localFilePathForUrl:originURL];
    NSLog(@"目标路径 === %@", destinationURL);
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:&error];
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:destinationURL error:&error];
    NSLog(@"文件移动失败 === %@", error.localizedDescription);
    
//    if (!error) {
        NSString *url = downloadTask.originalRequest.URL.absoluteString;
        self.activeDownload[url] = nil;
        NSInteger trackIndex = [self trackIndexForDownloadTask:downloadTask];
        if (trackIndex != -1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.songTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:trackIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            });
        }
//    }
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSString *downloadURL = downloadTask.originalRequest.URL.absoluteString;
    Download *download = self.activeDownload[downloadURL];
    self.progress.completedUnitCount = totalBytesWritten;
    self.progress.totalUnitCount = totalBytesExpectedToWrite;
    if (download) {
        download.progress = self.progress.fractionCompleted;
        NSString *totalSizeStr = [NSByteCountFormatter stringFromByteCount:totalBytesExpectedToWrite countStyle:NSByteCountFormatterCountStyleBinary];
        NSInteger trackIndex = [self trackIndexForDownloadTask:downloadTask];
        if (trackIndex != -1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                TrackCell *cell = [self.songTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:trackIndex inSection:0]];
                cell.progressView.progress = download.progress;
                cell.progesssLb.text = [NSString stringWithFormat:@"%.1f %% of %@", download.progress * 100, totalSizeStr];
                download.fileSizeText = [NSString stringWithFormat:@"%.1f %% of %@", download.progress * 100, totalSizeStr];
            });
        }
    }
}

#pragma mark - Private Methods
- (void)updateSearchResult: (NSData *)data
{
    [self.searchResults removeAllObjects];
    NSError *error;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSArray *resultArr = responseDic[@"results"];
    for (NSDictionary *trackDic in resultArr) {
        NSString *previewUrl = trackDic[@"previewUrl"] ?: @"";
        NSString *name = trackDic[@"trackName"] ?: @"";
        NSString *artist = trackDic[@"artistName"] ?: @"";
        TrackModel *trackModel = [[TrackModel alloc] initWithName:name artist:artist previewUrl:previewUrl];
        [self.searchResults addObject:trackModel];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.songTableView reloadData];
    });
}

/// 开始下载
- (void)startDownload: (TrackModel *)track
{
    NSString *urlString = track.previewUrl;
    NSURL *url = [NSURL URLWithString:urlString];
    Download *download = [[Download alloc] initWithUrl:urlString];
    download.downloadTask = [self.downloadSession downloadTaskWithURL:url];
    [download.downloadTask resume];
    download.isDownloading = YES;
    self.activeDownload[download.url] = download;
}

/// 暂停下载
- (void)pauseDownload: (TrackModel *)track
{
    NSString *urlString = track.previewUrl;
    Download *download = self.activeDownload[urlString];
    if (download.isDownloading) {
        [download.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            download.resumeData = resumeData;
        }];
        download.isDownloading = NO;
    }
}

/// 取消下载
- (void)cancelDownload: (TrackModel *)track
{
    NSString *urlString = track.previewUrl;
    Download *download = self.activeDownload[urlString];
    [download.downloadTask cancel];
    self.activeDownload[urlString] = nil;
}

/// 恢复下载
- (void)resumeDownload: (TrackModel *)track
{
    NSString *urlString = track.previewUrl;
    Download *download = self.activeDownload[urlString];
    if (download.resumeData) {
        download.downloadTask = [self.downloadSession downloadTaskWithResumeData:download.resumeData];
        [download.downloadTask resume];
        download.isDownloading = YES;
    } else {
        NSURL *url = [NSURL URLWithString:download.url];
        download.downloadTask = [self.downloadSession downloadTaskWithURL:url];
        [download.downloadTask resume];
        download.isDownloading = YES;
    }
}

/// 播放
- (void)playDownload: (TrackModel *)track
{
    NSString *urlString = track.previewUrl;
    NSURL *localURL = [self localFilePathForUrl:urlString];
    MPMoviePlayerController *movieplayer = [[MPMoviePlayerController alloc] initWithContentURL:localURL];
    [self presentViewController:movieplayer animated:YES completion:nil];
}

- (NSURL *)localFilePathForUrl: (NSString *)previewUrl {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *url = [[NSURL alloc] initWithString:previewUrl];
    NSString *fullPath = [documentPath stringByAppendingPathComponent:url.lastPathComponent];
    return [NSURL fileURLWithPath:fullPath];
}

- (BOOL)localFileExistsForTrack: (TrackModel *)track
{
    NSString *urlString = track.previewUrl;
    NSURL *localUrl = [self localFilePathForUrl:urlString];
    BOOL isDir = NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:[localUrl path] isDirectory:&isDir];
}

- (NSInteger)trackIndexForDownloadTask: (NSURLSessionDownloadTask *)downloadTask
{
    NSString *url = downloadTask.originalRequest.URL.absoluteString;
    NSInteger index = 0;
    for (TrackModel *track in self.searchResults) {
        if ([track.previewUrl isEqualToString:url]) {
            return index;
        }
        index += 1;
    }
    return -1;
}

#pragma mark - Setters and Getters
- (NSMutableDictionary *)activeDownload
{
    if (!_activeDownload) {
        _activeDownload = [NSMutableDictionary dictionary];
    }
    return _activeDownload;
}

- (NSURLSession *)defaultSession
{
    if (!_defaultSession) {
        _defaultSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _defaultSession;
}

- (NSURLSession *)downloadSession
{
    if (!_downloadSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"bgSessionConfiguration"];
        _downloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return _downloadSession;
}

- (NSURLSessionDataTask *)dataTask
{
    if (!_dataTask) {
        
    }
    return _dataTask;
}

- (NSMutableArray *)searchResults
{
    if (!_searchResults) {
        _searchResults = [NSMutableArray array];
    }
    return _searchResults;
}

- (UITapGestureRecognizer *)tapRecognizer
{
    if (!_tapRecognizer) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventTapRecognizerResponse)];
    }
    return _tapRecognizer;
}

- (NSProgress *)progress
{
    if (!_progress) {
        _progress = [NSProgress new];
    }
    return _progress;
}

@end
