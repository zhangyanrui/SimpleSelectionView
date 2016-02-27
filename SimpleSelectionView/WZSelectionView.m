//
//  WZSelectionView.m
//  LeFilm
//
//  Created by  Will on 15/11/12.
//  Copyright © 2015年 LEVP. All rights reserved.
//

#import "WZSelectionView.h"

static NSString *const kSelectionCellNameKey = @"SelectionCellNameKey";
static NSString *const kSelectionCellImageNameKey = @"SelectionCellImageNameKey";
static NSString *const kSelectionCellTagKey = @"SelectionCellTagKey";
static NSString *const kSelectionViewShouldDismissKey = @"SelectionViewShouldDismissKey";

#define kColorWithHex(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0f green:((c>>8)&0xFF)/255.0f blue:(c&0xFF)/255.0f alpha:1.0f]



#pragma mark - WZSelectionItems

@interface WZSelectionItems : NSObject <WZSelectionItemsProtocol>

@property (nonatomic, strong) NSMutableArray *itemsArray;
- (NSInteger) count;

@end


@implementation WZSelectionItems

- (instancetype)init{
    self = [super init];
    if (self) {
        self.itemsArray = [NSMutableArray array];
    }
    return self;
}


- (void)addItemWithLabelText:(NSString *)labelText imageName:(NSString *)imageName shouldDismiss:(BOOL)shouldDismiss{
    if (labelText && [labelText isKindOfClass:[NSString class]] && imageName && [imageName isKindOfClass:[NSString class]]) {
        NSDictionary *itemDic = [NSDictionary dictionaryWithObjectsAndKeys: labelText, kSelectionCellNameKey, imageName, kSelectionCellImageNameKey, [NSNumber numberWithBool:shouldDismiss], kSelectionViewShouldDismissKey, nil];
        [self.itemsArray addObject:itemDic];
    }
}

- (NSInteger)count{
    return self.itemsArray.count;
}

@end



#pragma mark - WZSelectionCell

@interface WZSelectionCell : UITableViewCell

@property (nonatomic, strong)UIImageView *pictureView;
@property (nonatomic, strong)UILabel *labelView;
@property (nonatomic, strong)UIView *lineView;
@property (nonatomic, strong)NSDictionary *infoDictionary;

@end

@implementation WZSelectionCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //图片
        UIImageView *pictureView=[[UIImageView alloc]init];
        self.pictureView=pictureView;
        pictureView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:pictureView];
        
        //文字
        UILabel *labelView=[[UILabel alloc]init];
        labelView.backgroundColor = [UIColor clearColor];
        labelView.font=[UIFont systemFontOfSize:16];
        [labelView setTextColor:[UIColor colorWithRed:39/255.0 green:44/255.0 blue:47/255.0 alpha:1.0]];
        self.labelView=labelView;
        [self.contentView addSubview:labelView];
        
        //下划线
        UIView *lineView=[[UIView alloc]init];
        self.lineView=lineView;
        lineView.backgroundColor = kColorWithHex(0xd2d5d9);
        [self.contentView addSubview:lineView];
        
        UIView *selectedBackgroundView = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = kColorWithHex(0xf5f6f7);
        self.selectedBackgroundView = selectedBackgroundView;

        self.contentView.backgroundColor = kColorWithHex(0xffffff);
        
    }
    return self;
}


-(void)layoutSubviews
{
    
    [super layoutSubviews];
    
    CGFloat picW=24;
    CGFloat picH=24;
    CGFloat picX=8;
    CGFloat picY=self.bounds.size.height*0.5-picH*0.5;
    self.pictureView.frame=CGRectMake(picX, picY, picW, picH);
    
    CGFloat labelX=CGRectGetMaxX(self.pictureView.frame)+8;
    CGFloat labelY=0;
    CGFloat labelW=self.bounds.size.width-labelX;
    CGFloat labelH=self.bounds.size.height;
    self.labelView.frame=CGRectMake(labelX, labelY, labelW, labelH);
    
    
    CGFloat lineX=0;
    CGFloat lineW=self.bounds.size.width-lineX;
    CGFloat lineH=0.5;
    CGFloat lineY=self.bounds.size.height-lineH;
    self.lineView.frame=CGRectMake(lineX, lineY, lineW, lineH);
    
}

-(void)setInfoDictionary:(NSDictionary *)infoDictionary{
    _infoDictionary = infoDictionary;
    NSString *imageName = infoDictionary[kSelectionCellImageNameKey];
    if (imageName && [imageName isKindOfClass:[NSString class]] && imageName.length) {
        self.pictureView.image=[UIImage imageNamed:imageName];
    }
    
    NSString *nameStr = infoDictionary[kSelectionCellNameKey];
    self.labelView.text = [nameStr description];
    
}
@end



#pragma mark - WZSelectionCancelCell

@interface WZSelectionCancelCell : UITableViewCell

@property (nonatomic, strong)UILabel *labelView;

@end

@implementation WZSelectionCancelCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *labelView=[[UILabel alloc]init];
        labelView.text=@"取消";
        [self.contentView addSubview:labelView];
        self.labelView=labelView;
        labelView.textAlignment=NSTextAlignmentCenter;
        labelView.font=[UIFont systemFontOfSize:16];
        [labelView setTextColor:[UIColor colorWithRed:104/255.0 green:165/255.0 blue:225/255.0 alpha:1.0]];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat labelX=0;
    CGFloat labelY=0;
    CGFloat labelW=self.bounds.size.width;
    CGFloat labelH=self.bounds.size.height;
    self.labelView.frame=CGRectMake(labelX, labelY, labelW, labelH);
}

@end






#pragma mark - WZSelectionView


@interface WZSelectionView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong)UITableView *selectionTableView;
@property (nonatomic, strong)WZSelectionItems *items;
@property (nonatomic, copy) void (^seletedBlock)(NSInteger selectedIndex);

@end


@implementation WZSelectionView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        self.frame = keyWindow.bounds;

        
        UIView *gesView = [[UIView alloc] initWithFrame:self.bounds];
        gesView.backgroundColor = [UIColor clearColor];
        [gesView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf)]];
        [self addSubview:gesView];
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        
        [self addSubview:self.selectionTableView];
    }
    return self;
}


#pragma mark  - Public Method

+ (void)showWithItemsBlock:(ITtemsBlock)itemsBlock selectedBlock:(SelectedTodoBlock)selectedBlock{
 
    WZSelectionView *selectionView = [[WZSelectionView alloc] initWithFrame:CGRectZero];
    [selectionView showWithItemsBlock:itemsBlock selectedBlock:selectedBlock];
    
}

- (void)showWithItemsBlock:(ITtemsBlock)itemsBlock selectedBlock:(SelectedTodoBlock)selectedBlock{

    self.seletedBlock = selectedBlock;
    itemsBlock(self.items);
    
    NSAssert(self.items.count>0, @"You must implement the protcol With method - (void)addItemWithLabelText: imageName: shouldDismiss:In ITtemsBlock");
    
    CGFloat tableViewHeight = (self.items.count + 1) * kSelectionCellHeight;
    
    if (tableViewHeight <= KSelectionViewMaxHeight) {
        self.selectionTableView.scrollEnabled = NO;
    }else{
        self.selectionTableView.scrollEnabled = YES;
    }
    
    tableViewHeight = tableViewHeight > KSelectionViewMaxHeight ? KSelectionViewMaxHeight : tableViewHeight;
    self.selectionTableView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, tableViewHeight);
    
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    self.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect selectionTableViewFrame = self.selectionTableView.frame;
        selectionTableViewFrame.origin.y = [UIScreen mainScreen].bounds.size.height - tableViewHeight;
        self.selectionTableView.frame = selectionTableViewFrame;
    }];

}

#pragma mark - Actions

- (void)hideSelf{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        CGRect selectionTableViewFrame = self.selectionTableView.frame;
        selectionTableViewFrame.origin.y = [UIScreen mainScreen].bounds.size.height;
        self.selectionTableView.frame = selectionTableViewFrame;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        [self removeFromSuperview];
    }];
    
    
}

#pragma mark - Getter

- (WZSelectionItems *)items{
    if (!_items) {
        _items = [[WZSelectionItems alloc] init];
    }
    return _items;
}


- (UITableView *)selectionTableView{
 
    if (!_selectionTableView) {
        _selectionTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _selectionTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _selectionTableView.dataSource=self;
        _selectionTableView.delegate=self;
    }
    return _selectionTableView;
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:{
            return self.items.count;
            break;
        }
        case 1:{
            return 1;
            break;
        }
        default:
            break;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *WZSelectionCellID=@"WZSelectionCell";
    static NSString *WZSelectionCancelCellID=@"WZSelectionCancelCell";
    
    UITableViewCell *aCell;
    
    switch (indexPath.section) {
        case 0:{
            WZSelectionCell *cell=[tableView dequeueReusableCellWithIdentifier:WZSelectionCellID];
            if (cell==nil) {
                cell=[[WZSelectionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WZSelectionCellID];
            }
            
            if (self.items.count > indexPath.row) {
                cell.infoDictionary = self.items.itemsArray[indexPath.row];
            }
            aCell = cell;
            break;
        }
            
        case 1:{
            WZSelectionCancelCell *cell=[tableView dequeueReusableCellWithIdentifier:WZSelectionCancelCellID];
            if (cell==nil) {
                cell=[[WZSelectionCancelCell  alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WZSelectionCancelCellID];
            }
            aCell = cell;
        }
            
        default:
            break;
    }
    
    if (!aCell) {
        aCell = [[UITableViewCell alloc] init];
    }
    
    return aCell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kSelectionCellHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.selectionTableView) {

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.section == 0) {
            self.seletedBlock(indexPath.row);
            if (self.items.itemsArray.count > indexPath.row) {
                BOOL shouldDismiss = [[self.items.itemsArray[indexPath.row] objectForKey:kSelectionViewShouldDismissKey] boolValue];
                if (shouldDismiss) {
                    [self hideSelf];
                }
            }
        } else {
             [self hideSelf];
        }
        
    }
}



@end
