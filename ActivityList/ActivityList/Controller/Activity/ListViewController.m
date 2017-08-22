//
//  ViewController.m
//  ActivityList
//
//  Created by admin on 2017/7/24.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "ListViewController.h"
#import "ActivityTableViewCell.h"
#import "ActivityModel.h"
#import "UIImageView+WebCache.h"
#import "DetailViewController.h"
#import "IssueViewController.h"
#import <CoreLocation/CoreLocation.h>
@interface ListViewController ()<UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>{
    NSInteger page;
    NSInteger perPage;
    NSInteger totalPage;
    BOOL isLoading;
    BOOL firstVisit;
}
- (IBAction)favoAction:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)SwitchAction:(UIBarButtonItem *)sender;
- (IBAction)searchAction:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UITableView *activityTableView;
@property (strong,nonatomic)NSMutableArray *arr;
@property(strong,nonatomic)UIImageView*zoomIv;
@property(strong,nonatomic)UIActivityIndicatorView *aiv;
@property(strong,nonatomic)CLLocationManager *locMgr;
@property(strong,nonatomic)CLLocation *location;
@property (weak, nonatomic) IBOutlet UIButton *CityBtn;

@end

@implementation ListViewController
//第一次将要开始渲染这个页面的时候
-(void)awakeFromNib{
    [super awakeFromNib];
}
//第一次来到这个页面的时候
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //[self networkRequest];
    //[self performSelector:@selector(networkRequest) withObject:nil afterDelay:2];
    //ActivityModel *activity=[[ActivityModel alloc]init];
   // activity.name=@"活动";
    [self naviConfig];
    [self uiLayout];
    [self loactionConfig];
    [self dataInitialize];
  
}
//每次将要来到这个页面的时候
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self LocationStart];
}
//每次到达了这个页面
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
//每次将要离开这个页面的时候
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
//每次离开这个页面的时候
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //获得当前页面的导航控制器所维系得到关于导航关系的数组。通过判断该数组中是否包含自己来得知当前操作是离开本页面还是退出本页面
    if (![self.navigationController.viewControllers containsObject:self]) {
        //这这里先释放所有监听（包括：Action事件；Protocol协议；Gesture手势；Notification通知...)
    }
}
//一旦退出这个页面的时候（并且所有的监听都已经全部被释放了）（防止崩溃）
-(void)dealloc{
    //在这里释放所有的内存（设置为nil）
}
//这个方法专门做导航条的控制
-(void)naviConfig{
    //设置导航条标题文字
    self.navigationItem.title=@"活动列表";
    //设置导航条的风格颜色
    self.navigationController.navigationBar.barTintColor=[UIColor brownColor];
    //设置导航条标题颜色
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor blueColor]};
    //设置导航条是否被隐藏
    self.navigationController.navigationBar.hidden=NO;
    //设置导航条上按钮的风格颜色
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    //设置是否需要毛玻璃效果
    self.navigationController.navigationBar.translucent=YES;
}
//这个方法是专门做界面的操作
- (void)uiLayout{
    //为表格视图创建footer（该方法可以去除表格视图多余的下划线）
    _activityTableView.tableFooterView = [UIView new];
    //创建
    [self refreshConfiguration];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loactionConfig{
    _locMgr = [CLLocationManager new];
    //签协议
    _locMgr.delegate = self;
    //识别定位到的设备位移多少距离进行一次识别
    _locMgr.distanceFilter = kCLDistanceFilterNone ;
    //设置定位精度（把地球分割成边长多少精度的方块）
    _locMgr.desiredAccuracy = kCLLocationAccuracyBest;

}
//这个方法处理开始定位
-(void)LocationStart{
//判断用户有没有选择过是否使用定位
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        //询问用户是否愿意使用定位
#ifdef __IPHONE_8_0
        if([_locMgr respondsToSelector:@selector(requestWhenInUseAuthorization)]){
            //使用“使用中打开定位”这个策略去运用定位功能
            [_locMgr requestWhenInUseAuthorization];
        }
#endif

    }
    //打开定位服务的开关（开始定位）
    [_locMgr startUpdatingLocation];
}
//初始化一个下拉刷新控件
-(void)refreshConfiguration{
    UIRefreshControl *refreshControl=[[UIRefreshControl alloc]init];
    refreshControl.tag=10001;
    //设置标题
    NSString *title =@"走你😇";
    //创建属性字典
    NSDictionary *attrDict=@{NSForegroundColorAttributeName:[UIColor redColor],NSBackgroundColorAttributeName:
        [UIColor brownColor]};
    //将文字和属性字典包裹成一个带属性的字符串
    NSAttributedString *attriTitle=[[NSAttributedString alloc] initWithString: title attributes:attrDict];
    refreshControl.attributedTitle=attriTitle;
    //设置风格颜色为黑色
    refreshControl.tintColor =[UIColor blackColor];
    //设置背景色
    refreshControl.backgroundColor=[UIColor groupTableViewBackgroundColor];
    //设置事件(定义用户触发下拉事件时执行的方法)
    [refreshControl addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventValueChanged];
    //将下拉刷新控件添加到activityTableView中（在tableView中，下拉刷新控件会自动放置在表格视图顶部后侧位置）
    [self.activityTableView addSubview:refreshControl];
}
/*
-(void)refreDate:(UIRefreshControl *)sender{
    //过2秒钟对结束下拉刷新响应
    [self performSelector:@selector(end) withObject:nil afterDelay:2];
}*/
-(void)end{
    //在activiTableView中，根据下标10001获得其子视图：下拉刷新控件
    UIRefreshControl *refresh=(UIRefreshControl *)[self.activityTableView viewWithTag:10001];
    //结束刷新
    [refresh endRefreshing];
}
//这个方法专门做数据的处理
-(void)dataInitialize{
    //初始化
    _arr=[NSMutableArray new];
    isLoading = NO;
    firstVisit = YES;
    //创建菊花膜
    _aiv=[Utilities getCoverOnView:self.view];
    [self refreshPage];

}
//在网络请求和
-(void)refreshPage{
    page=1;
    [self networkRequest];
}
//执行网络请求
-(void)networkRequest{
    perPage=10;
    
    
    if (!isLoading) {
        isLoading=YES;
        //在这里开启一个真实的网络请求
        //设置接口地址
        NSString *request = @"/event/list";
        //设置接口入参
        NSDictionary *parameter =@{@"page":@(page),@"perPage":@(perPage)};
        //开始请求
        [RequestAPI requestURL:request withParameters:parameter andHeader:nil byMethod:kGet andSerializer:kForm success:^(id responseObject) {
            //成功以后要做的事情在此处执行
            NSLog(@"responseObject=%@",responseObject);
            
            [self endAnimaton];
            if ([responseObject[@"resultFlag"]integerValue]==8001) {
                //业务逻辑成功的情况
                NSDictionary *result=responseObject[@"result"];
                NSArray *models=result[@"models"];
                NSDictionary *pagingInfo=result[@"pagingInfo"];
                totalPage =[pagingInfo[@"totalPage"]integerValue];
                if (page==1) {
                    //清空数组
                    [_arr removeAllObjects];
                }
                for(NSDictionary *dict in models) {
                    //用ActivityModel类中定义的初始化方法nitWIthDictionary:将遍历得来的字典dict转化成为ActivityModel对象
                    ActivityModel *activityModel=[[ActivityModel alloc] initWithDictionary:dict];
                    //将上述实例化好的ActivityModel对象插入
                    [_arr addObject:activityModel];
                }
                //刷新表格
                [_activityTableView reloadData];
            }else{
                //业务逻辑失败的情况
                NSString *errorMsg=[ErrorHandler getProperErrorString:[responseObject[@"resultFlag"]integerValue]];
                [Utilities popUpAlertViewWithMsg:errorMsg andTitle:nil onView:self];
            }
        } failure:^(NSInteger statusCode, NSError *error) {
            //失败以后要做的事情在此处执行
            NSLog(@"statusCode=%ld",(long)statusCode);
            [self endAnimaton];
            [Utilities popUpAlertViewWithMsg:@"请保持网络连接畅通" andTitle:nil onView:self];
        }];

    }
    }
//这个方法处理网络请求完成后所有不同类型的动画终止
-(void)endAnimaton{
    isLoading=NO;
    [_aiv stopAnimating];
    [self end];
}
//设置表格视图一共有多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//设置表格视图中每一组有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //对应数组有多少个
    return _arr.count;
}
//设置当一个细胞将要出现的时候的事情
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //判断是不是最后一行
    if (indexPath.row ==_arr.count-1) {
        //判断还有没有下一页存在
        if (page<totalPage) {
             //在这里执行上拉翻页的数据操作
            page ++;
            [self networkRequest];
        }
    }
}

//设置每一组中每一行的细胞长什么样
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //根据某个名字找到该名字在页面上对应的细胞
    //享元模型
    ActivityTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ActivityCell" forIndexPath:indexPath];
    //根据当前正在渲染的细胞的行号，从对应的数组中拿到这一行所匹配的活动字典
    ActivityModel *activity=_arr[indexPath.row];
    //打印imgUrl
    //NSLog(@"%@",activity.imgUrl);
    //将http请求的字符串转换为NSURL
    NSURL *URL=[NSURL URLWithString:activity.imgUrl];
    //依靠SDWebLmage来异步地下载一张远程路径下的图片并三级缓存在项目中，同时为下载的时间周期过程中设置一张临时占位图
    [cell.activityImageView sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"露营"]];
    //将URL给NSData（下载）
    //NSData *data=[NSData dataWithContentsOfURL: URL];
    //转化成图片
    //cell.activityImageView.image = [UIImage imageWithData:data];
    //给图片添加单击手势
    [self addTapGestureRecognizer:cell.activityImageView];
     //复合写法
    //cell.activityImageView.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:activity.imgUrl]]];
    cell.actiivityNameLabel.text=activity.name;
    cell.activityInFolabel.text=activity.content;
    cell.activityLikeLabel.text=[NSString stringWithFormat:@"顶:%ld",(long)activity.like];
    cell.activityUnlikeLabel.text=[NSString stringWithFormat:@"踩:%ld",(long)activity.unlike ];
    //给每一行的收藏按钮打上下标，用了区分它是哪一行的按钮
    cell.favoBtn.tag=100000+indexPath.row;
   
    [cell.favoBtn setTitle:activity.isFavo?@"取消收藏":@"收藏" forState:UIControlStateNormal];
    //调用longPress的细胞
    [self longPress:cell];
    


    return cell;
}
//添加一个长按手势事件
-(void)longPress:(UITableViewCell *)cell{
    //初始化一个长按手势，设置相应的事件为choose:
    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(choose :)];
    //设置长按手势相应的时间
    longPress.minimumPressDuration=1.0;
    //添加手势给cell
    [cell addGestureRecognizer:longPress];

}
//添加单击手势事件
-(void)addTapGestureRecognizer:(id)any{
    //初始化一个单击手势，设置相应的事件（名字）为tapClick:
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer  alloc] initWithTarget:self action:@selector(tapClick:)];
    //将手势给入参
    [any addGestureRecognizer:tap];
}
//单击手势响应事件
-(void)tapClick:(UITapGestureRecognizer *)tap{
    if (tap.state ==UIGestureRecognizerStateRecognized) {
        //NSLog(@"图片被单击");
        //拿到单击手势在_activityTableView中的位置
        CGPoint location=[tap locationInView:_activityTableView];
        //通过上诉的点拿到在_activityTableView对应的indexPath
        NSIndexPath *indexPath=[_activityTableView indexPathForRowAtPoint:location];
        //防范式编程（放大）
        if (_arr != nil && _arr.count != 0) {
            //根据行号拿到数组中对应的数据
            ActivityModel *activity= _arr[indexPath.row];
            //设置大图片的位置大小
            _zoomIv = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
            //设置回小图片(用户交互启用)
            _zoomIv.userInteractionEnabled=YES;
            _zoomIv.backgroundColor=[UIColor blackColor];
            //_zoomIv.image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:activity.imgUrl]]];
            [_zoomIv sd_setImageWithURL:[NSURL URLWithString:activity.imgUrl] placeholderImage:[UIImage imageNamed:@"露营"]];
            //设置图片放入内容模式
            _zoomIv.contentMode = UIViewContentModeScaleAspectFit;
            //获得窗口实例，并将大图放置到窗口实例上，根据苹果规则，后添加的控件会覆盖前添加的控件
            [[UIApplication sharedApplication].keyWindow addSubview:_zoomIv];
            [self.view addSubview:_zoomIv];
            UITapGestureRecognizer *zoomIVTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomTap:)];
            [_zoomIv addGestureRecognizer:zoomIVTap];
        }

    }
    
}
//大图单击手势响应事件
-(void)zoomTap:(UITapGestureRecognizer *)tap{
    if (tap.state ==UIGestureRecognizerStateRecognized) {
        //把大图本身的东西扔掉（大图的手势）
        [_zoomIv removeGestureRecognizer:tap];
        //把自己父级视图中移除
        [_zoomIv removeFromSuperview];
        //彻底消失（以后就不会造成内存的滥用）
        _zoomIv =nil;
    }
}
//长按手势响应事件
-(void)choose: (UILongPressGestureRecognizer *)longPress{
    //判断手势的状态（长按手势有时间间隔，对应的会有开始和结束两种状态）
    /*if (longPress.state==UIGestureRecognizerStateBegan) {
        NSLog(@"长按了！");
    }else*/ if (longPress.state==UIGestureRecognizerStateEnded){
        NSLog(@"结束长按");
        //拿到长按手势在_activityTableView中的位置
        CGPoint location=[longPress locationInView:_activityTableView];
        //通过上诉的点拿到在_activityTableView对应的indexPath
        NSIndexPath *indexPath=[_activityTableView indexPathForRowAtPoint:location];
        //防范式编程
        if (_arr != nil && _arr.count != 0) {
            //根据行号拿到数组中对应的数据
            ActivityModel *activity= _arr[indexPath.row];
            //创建弹窗控制器
            UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"复制操作" message:@"复制活动名称或内容" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *actionA=[UIAlertAction actionWithTitle:@"复制活动名称" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
                //创建复制板
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                //将活动名称复制
                [pasteboard setString:activity.name];
                NSLog(@"复制内容：%@",pasteboard.string);
            }];
            UIAlertAction *actionB=[UIAlertAction actionWithTitle:@"复制活动内容" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){
                //创建复制板
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                //将活动名称复制
                [pasteboard setString:activity.content];
            }];
            UIAlertAction *actionC=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:actionC];
            [alert addAction:actionB];
            [alert addAction:actionA];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
        
    }
}
//设置每一组中每一行细胞的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取三要素（计算文字高度的三要素）
    //1.文字内容
    ActivityModel *activity=_arr[indexPath.row];
    NSString *activityContent=activity.content;
    //2.文字大小
    //拿到对应的方法
    ActivityTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ActivityCell" ];
    UIFont *font=cell.activityInFolabel.font;
    //3.宽度尺寸
    //获得屏幕宽度在减去30
    CGFloat width=[UIScreen mainScreen].bounds.size.width -30;
    //设置屏幕高度
    CGSize size=CGSizeMake(width,1000);
    //根据三元素计算尺寸
    CGFloat height=[activityContent boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size.height;
    //活动内容标签的原点Y的位置+活动内容标签根据文字自适应大小后获得的高度+活动内容标签距离细胞底部的间距
    return cell.activityInFolabel.frame.origin.y+height+10;
}
//设置每一组中每一行细胞被点击以后要做的事
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //判断当前tableView是否为_activityTableView（这个条件判断常用在一个页面有多个tableView的时候）
    if ([tableView isEqual:_activityTableView]) {//取消选中
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}


- (IBAction)favoAction:(UIButton *)sender forEvent:(UIEvent *)event {
    if (_arr !=nil&&_arr.count !=0){
    //通过按钮的下标值减去10000拿到行号，再通过行号拿到对应的数据模型
    ActivityModel *activity= _arr[sender.tag-100000];
        NSString *message=activity.isFavo ?@"是否取消收藏该活动":@"是否收藏该活动";
    //创建弹出框，标题为@“提示”，内容为@“是否收藏该活动
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    //创建取消按钮
    UIAlertAction *actionA=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:/*代码块*/^(UIAlertAction * _Nonnull action) {
        
    }];
    //创建确定按钮
    UIAlertAction *actionB=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(activity.isFavo){
            activity.isFavo=NO;
        }else{
            activity.isFavo=YES;
        }
        //重新加载数据
        [self.activityTableView reloadData];
    }];
    //将按钮添加到弹出框，（添加按钮的顺序决定了按钮的排版：从左到右；从上往下。取消风格的按钮会在最左边）
    [alert addAction:actionA];
    [alert addAction:actionB];
    //用presentViewController的方式，以model的方式显示另一个页面（显示弹出框）
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    }
}

- (IBAction)searchAction:(UIBarButtonItem *)sender {
    //1.获得要跳转的页面的实例
    IssueViewController *issueVC=[Utilities getStoryboardInstance:@"Issue" byIdentity:@"Issue"];
    UINavigationController *nc=[[UINavigationController alloc] initWithRootViewController:issueVC];
    //2.用某种方式跳转到上述页面（这里用Model的方式跳转）
    [self presentViewController:nc animated:YES completion:nil];
    //用push的方法跳转[self.navigationController pushViewController:nc animated:YES];
}
//当某一个跳转行为将要发生的时候
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"List2Detail"]) {
        //当从列表页到详情页的这个跳转要发生的时候
        //1.获取要传递到下一页去的数据
        NSIndexPath *indexPath=[_activityTableView indexPathForSelectedRow];
        ActivityModel *activity=_arr[indexPath.row];
        //2.获取下一页这个实例
        DetailViewController *detailVC=segue.destinationViewController;
        //3.把数据给下一页预备好的接收容器
        detailVC.activity1 =activity;
    }
}
- (IBAction)SwitchAction:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"LeftSwitch" object:nil];
}
//定位失败的情况
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    if(error){
        switch (error.code) {
            case kCLErrorNetwork:
                [Utilities popUpAlertViewWithMsg:NSLocalizedString(@"NetworkError", nil) andTitle:nil onView:self];
                break;
            case kCLErrorDenied:
               [Utilities popUpAlertViewWithMsg:NSLocalizedString(@"GPSDisabled", nil) andTitle:nil onView:self];
                break;
            case kCLErrorLocationUnknown:
            [Utilities popUpAlertViewWithMsg:NSLocalizedString(@"LocationUnkonw", nil) andTitle:nil onView:self];
                break;
            default:[Utilities popUpAlertViewWithMsg:NSLocalizedString(@"SystemError", nil) andTitle:nil onView:self];
                break;
                break;
        }
    }
}
//定位成功的方法
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    NSLog(@"纬度：%f",newLocation.coordinate.latitude);
    NSLog(@"经度：%f",newLocation.coordinate.longitude);
    _location = newLocation;
    //用flag思想判断是否可以去根据定位拿到城市
    if(firstVisit){
        firstVisit = !firstVisit;
        //根据定位拿到城市
       [self getRegeoViaCoordinate];
    }
}

-(void)getRegeoViaCoordinate{
    //duration表示从NOW开始过3个SEC
    dispatch_time_t duration = dispatch_time(DISPATCH_TIME_NOW, 3 *NSEC_PER_SEC);
    //用duration这个设置好的策略去做某些事
    dispatch_after(duration, dispatch_get_main_queue(), ^{
       //正式做事情
        CLGeocoder *geo = [CLGeocoder new];
        //反向地理编码
        [geo reverseGeocodeLocation:_location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            if(!error){
                CLPlacemark *first = placemarks.firstObject;
                NSDictionary *locDict = first.addressDictionary;
                NSLog(@"locdict：%@",locDict);
                NSString *cityStr = locDict[@"City"];
               
                cityStr = [cityStr substringToIndex:(cityStr.length - 1)];
                NSLog(@"City:%@",cityStr);
                
            
            if ([_CityBtn.currentTitle isEqualToString:@"苏州"]) {
                    NSLog(@"哈哈");
                 _CityBtn.titleLabel.text = cityStr;
            }else{
                
            }
            }
        }];
          //关掉开关
           [_locMgr stopUpdatingLocation];
        
            });
   
}
@end
