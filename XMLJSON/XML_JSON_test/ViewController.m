//
//  ViewController.m
//  XML_JSON_test
//
//  Created by 刘杨 on 15/9/28.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "GDataXMLNode.h"
#import "JSONKit.h"

@interface ViewController ()<NSXMLParserDelegate>{
    NSString *_currentElements;//用来记录的标签
}
@property (nonatomic, strong) NSMutableArray *xmlParsers;
@property (nonatomic, strong) NSMutableArray *xmlDoms;
@property (nonatomic, strong) NSMutableArray *jsonSerialzations;
@property (nonatomic, strong) NSMutableArray *jsonKits;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //xml解析
    //1.使用苹果自带代理方法解析xml
    
    /*      演示用本地数据
     *
     *      xml是根据标签，一个个赋值，会无数次的开打标签，关闭标签，标签和标签之间的赋值流程：
     先打开标签，然后取值，关闭标签，再取一次值，这样无限循环知道全部xml数据被获取下来
     */

    /*
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Student" ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    //设置parser一些属性
    [parser setShouldProcessNamespaces:NO];//处理命名空间
    [parser setShouldReportNamespacePrefixes:NO];//报告命名前缀
    parser.delegate = (id<NSXMLParserDelegate>)self;
    [parser parse];
    */
    
    /*
    //2.使用苹果自带的方法解析json
    NSString *path = [[NSBundle mainBundle] pathForResource:@"student" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.jsonSerialzations = [NSMutableArray array];
    NSError *error = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (!error) {
        NSLog(@"解析成功");
        for (NSDictionary *dict in array) {
            [self.jsonSerialzations addObject:[Person personWithDict:dict]];
        }
    }
    for (Person *person in self.jsonSerialzations) {
        NSLog(@"name %@ number %@ hobby %@", person.name, person.number, person.hobby);
    }
     */
    
    /*
    //3.使用第三方框架解析xml
    //要配置
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Student" ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.xmlDoms = [NSMutableArray array];
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *element = [document rootElement];//拿到根节点
    NSArray *array = [element elementsForName:@"student"];//拿到根节点对应的数组
    for (GDataXMLElement *element in array) {
        //拿到各个的根节点
        GDataXMLElement *name = [element elementsForName:@"name"].lastObject;
        GDataXMLElement *sex = [element elementsForName:@"sex"].lastObject;
        GDataXMLElement *phone = [element elementsForName:@"phone"].lastObject;
        //给模型赋值
        Person *person = [[Person alloc] init];
        person.name = [name stringValue];
        person.sex = [sex stringValue];
        person.phone = [phone stringValue];
        [self.xmlDoms addObject:person];
    }
    for (Person *person in self.xmlDoms) {
        NSLog(@"name %@ sex %@ phone %@", person.name, person.sex, person.phone);
    }
     */
    
    /*
    //4.使用JSONKit解析json
    NSString *path = [[NSBundle mainBundle] pathForResource:@"student" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    self.jsonKits = [NSMutableArray array];
    NSArray *array = [data objectFromJSONData];
    for (NSDictionary *dict in array) {
        [self.jsonKits addObject:[Person personWithDict:dict]];
    }
    for (Person *person in self.jsonKits) {
        NSLog(@"name %@ number %@ hobby %@", person.name, person.number, person.hobby);
    }
     */
}


//开始读取文档
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    //在这里面要做的事情就是初始化数组，用来存取模型
    self.xmlParsers = [NSMutableArray array];
}
//打开标签
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict{
    if ([elementName isEqualToString:@"student"]) {
        [self.xmlParsers addObject:[[Person alloc] init]];//初始化一个person对象添加到数组里
    }
    _currentElements = elementName;//记录当前的标签
}
//取值，值就是string
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    Person *person = self.xmlParsers.lastObject;//取出数组中最后一个元素，因为是刚刚初始化的没有被赋值的
    if ([_currentElements isEqualToString:@"name"]) {
        person.name = string;
    }else if([_currentElements isEqualToString:@"sex"]){
        person.sex = string;
    }else if ([_currentElements isEqualToString:@"phone"]){
        person.phone = string;
    }
}
//关闭标签
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    _currentElements = nil;
}
//关闭文档
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    //打印验证
    for (Person *person in self.xmlParsers) {
        NSLog(@"name %@ sex %@ phone %@", person.name, person.sex, person.phone);
    }
}
















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
