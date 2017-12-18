# AlertOrActionSheetDemo 功能描述:

### 一、模仿系统的``UIActionSheet``,  封装了一个多样式的``ActionSheetView``,  用法简单,导入头文件,  ``OKActionSheetView.h``使用;

### 使用pod导入方法:  pod 'OKAlertContrActionSheet', '~> 0.0.2'

### 1. 顶部下拉弹框样式:

![顶部下拉弹框样式](http://ww1.sinaimg.cn/large/b04498f4gw1fb7s2nnd42g20ab0j1juq.gif)

#### 代码用法:
```
[OKActionSheetView actionSheetByTopSquare:^(NSInteger buttonIndex) {
        NSString *tip = [NSString stringWithFormat:@"点击了第%zd行",buttonIndex];
        showAlertToast(tip);
        
    } cancelBlock:^{
        showAlertToast(@"点击背景取消");
        
    } superView:self.view position:CGPointMake(0, 64) buttonTitleArr:@[@"我的车辆",@"添加车辆",@"常见问题1",@"常见问题2",@"常见问题3",@"常见问题4",@"常见问题5"] buttonImageArr:@[@"myCar-nor",@"addCar-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor",@"commonQut-nor"]];
```

### 2. 底部上拉弹框直角样式:

![底部上拉弹框直角样式](http://ww3.sinaimg.cn/large/b04498f4gw1fb7sjbd7chg20ab0j1tak.gif)

#### 代码用法:
```
[OKActionSheetView actionSheetByBottomSquare:^(NSInteger buttonIndex) {
        NSString *tip = [NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex];
        showAlertToast(tip);
    } cancelBlock:^{
        showAlertToast(@"点击背景取消");
        
    } WithTitle:@"测试底部按钮" cancelButtonTitle:@"取消" otherButtonTitleArr:@[@"按钮1",@"按钮2",@"按钮3",@"按钮4",@"按钮5",@"按钮6",@"按钮7",@"按钮8"]];
```

### 3. 底部上拉弹框圆角样式:

![底部上拉弹框圆角样式](http://ww2.sinaimg.cn/large/b04498f4gw1fb7sl8lsisg20ab0j10uv.gif)

#### 代码用法:
```
[OKActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex) {
        NSString *tip = [NSString stringWithFormat:@"点击了第%zd行",buttonIndex];
        showAlertToast(tip);
        
    } cancelBlock:^{
        showAlertToast(@"点击背景取消");
        
    } WithTitle:@"测试底部按钮" cancelButtonTitle:@"取消" otherButtonTitleArr:@[@"按钮1",@"按钮2",@"按钮3",@"按钮4",@"按钮5",@"按钮6",@"按钮7",@"按钮8"]];
```

### 二、封装系统提示框, 兼容iOS9以下的``UiAlertView``, 和iOS9以上的``UIAlertController``;

### 1. 普通两个按钮弹框样式:

![普通两个按钮弹框样式](http://ww4.sinaimg.cn/large/b04498f4gw1fb7smu3sgmg20ab0j0n2b.gif)

#### 代码用法:
```
[OKAlertController alertWithCallBlock:^(NSInteger buttonIndex) {
        NSString *tip = [NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex];
        showAlertToast(tip);
        
    } title:nil message:@"普通弹框" cancelButtonTitle:@"取消" otherButtonTitles:@"确定1",@"确定2", nil];
```

### 2. 普通两个以上按钮弹框样式:

![普通两个以上按钮弹框样式](http://ww1.sinaimg.cn/large/b04498f4gw1fb7sodu1lqg20ab0j078x.gif)

#### 代码用法:
```
[OKAlertController alertWithCallBlock:^(NSInteger buttonIndex) {
        NSString *tip = [NSString stringWithFormat:@"点击了第%zd个按钮",buttonIndex];
        showAlertToast(tip);
        
    } title:@"温馨提示" message:@"显示两个以上按钮" cancelButtonTitle:@"取消" otherButtonTitles:@"确定1",@"确定2",@"确定3", nil];
```

### 3. 系统带输入弹框弹框样式:

![系统带输入弹框弹框样式](http://ww4.sinaimg.cn/large/b04498f4gw1fb7spjpqwug20ab0j00zf.gif)

#### 代码用法:
```
[OKAlertController inputAlertWithTitle:@"请输入" placeholder:@"输入弹框控件" cancelTitle:@"取消" otherTitle:@"确定" buttonBlock:^(NSString *inputText) {
        NSString *tip = [NSString stringWithFormat:@"您输入了:\n%@",inputText];
        showAlertToast(tip);
        
    } cancelBlock:^{
        showAlertToast(@"点击了取消按钮");
    }];
```

