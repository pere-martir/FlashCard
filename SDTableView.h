//
//  SDTableView.h
//  http://stackoverflow.com/questions/1483581/get-notified-when-uitableview-has-finished-asking-for-data

#ifndef FlashCard_SDTableView_h
#define FlashCard_SDTableView_h


@protocol SDTableViewDelegate <NSObject, UITableViewDelegate>
@required
- (void)willReloadData;
- (void)didReloadData;
- (void)willLayoutSubviews;
- (void)didLayoutSubviews;
@end

@interface SDTableView : UITableView

@property(nonatomic,assign) id <SDTableViewDelegate> delegate;

@end;

#endif
