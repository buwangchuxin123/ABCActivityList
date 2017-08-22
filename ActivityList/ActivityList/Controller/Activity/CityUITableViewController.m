//
//  CityUITableViewController.m
//  ActivityList
//
//  Created by admin on 2017/8/19.
//  Copyright © 2017年 Education. All rights reserved.
//

#import "CityUITableViewController.h"

@interface CityUITableViewController ()
@property (strong, nonatomic)NSDictionary *cities;
- (IBAction)CityAction:(UIButton *)sender forEvent:(UIEvent *)event;
@property (strong, nonatomic)NSArray *keys;
@end

@implementation CityUITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self naviConfig];
    [self dataInitialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)naviConfig{
    //设置导航条标题文字
    self.navigationItem.title=@"城市列表";
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
    //为导航条左上角创建一个按钮
    UIBarButtonItem *left =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem =left;
}
//用Model的方式返回上一页
-(void)backAction{
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}
-(void)dataInitialize{
    //创建文件管理器
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //获取要读取的文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"Cities" ofType:@"plist"];
    //判断路径是否存在文件
    if ([fileMgr fileExistsAtPath:filePath]) {
        //将文件内容读取为对应的格式
        NSDictionary *fileContent = [NSDictionary dictionaryWithContentsOfFile:filePath];
        //判断读取到的文件是否损坏
        if (fileContent) {
            NSLog(@"fileContent = %@",fileContent);
            _cities = fileContent;
            //提取字典中所有的键
            NSArray *rawKeys = [fileContent allKeys];
            //根据拼音首字母进行能够识别多音字的升序排序
            _keys = [rawKeys sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        }
    }

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //获取当前正在渲染组的名称
    NSString *key = _keys[section];
    //根据组的名称，作为键来查询到对应的值（这个值就是这一组城市对应城市数组）
    NSArray *sectionCity = _cities[key];
    //返回这一组城市的个数来作为行数
    return sectionCity.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
    NSString *key = _keys[indexPath.section];
    NSArray *sectionCity = _cities[key];
    NSDictionary *city= sectionCity[indexPath.row];
    cell.textLabel.text = city[@"name"];
    return cell;
}
//设置组的标题文字
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _keys[section];
}
//设置section header的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.f;
}

//设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//设置右侧快捷键栏
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return _keys;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)CityAction:(UIButton *)sender forEvent:(UIEvent *)event {
}
@end
