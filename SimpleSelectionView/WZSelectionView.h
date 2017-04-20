//
//  WZSelectionView.h
//  LeFilm
//
//  Created by  Will on 15/11/12.
//  Copyright © 2015年 LEVP. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kSelectionCellHeight 58
#define KSelectionViewMaxHeight 320

@protocol WZSelectionItemsProtocol <NSObject>

@required
- (void)addItemWithLabelText:(NSString *)labelText imageName:(NSString *)imageName shouldDismiss:(BOOL)shouldDismiss;

@end

typedef void(^ITtemsBlock)(id <WZSelectionItemsProtocol> items);
typedef void(^SelectedTodoBlock)(NSInteger selectedTag);

@interface WZSelectionView : UIView

+ (void)showWithItemsBlock:(ITtemsBlock)itemsBlock selectedBlock:(SelectedTodoBlock)selectedBlock;

@end
