# JellyEffect
qq粘性效果，果冻效果
###直接在你的控制器使用
```
	ETBubbing *bubbing = [[ETBubbing alloc] init];
    bubbing.frame = CGRectMake(30, 30, 40, 40);
    bubbing.image = [UIImage imageNamed:@"doubi"];
    bubbing.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:bubbing];
``