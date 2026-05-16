if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
class Index extends ViewV2 {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda, extraInfo) {
        super(parent, elmtId, extraInfo);
        this.finalizeConstruction();
    }
    public resetStateVarsOnReuse(params: Object): void {
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(21:5)", "entry");
            Column.width('100%');
            Column.height('100%');
            Column.background('#F1F3F5');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 1. 标题区
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(23:7)", "entry");
            // 1. 标题区
            Column.width('100%');
            // 1. 标题区
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('手持弹幕');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(24:9)", "entry");
            Text.fontSize(26);
            Text.fontColor('#000000');
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ left: 16 });
            Text.height(56);
        }, Text);
        Text.pop();
        // 1. 标题区
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 2. 预览区
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(35:7)", "entry");
            // 2. 预览区
            Column.width('100%');
            // 2. 预览区
            Column.margin({ top: 28 });
            // 2. 预览区
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('预览');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(36:9)", "entry");
            Text.fontSize(14);
            Text.fontColor('#99000000');
            Text.fontWeight(FontWeight.Medium);
            Text.margin({ left: 28 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 弹幕展示框
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(43:9)", "entry");
            // 弹幕展示框
            Column.width('100%');
            // 弹幕展示框
            Column.height(199);
            // 弹幕展示框
            Column.backgroundColor('#E5E5EA');
            // 弹幕展示框
            Column.padding({
                top: 24,
                right: 16,
                bottom: 24,
                left: 16
            });
            // 弹幕展示框
            Column.margin({ top: 8 });
            // 弹幕展示框
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 弹幕滚动区域
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/Index.ets(45:11)", "entry");
            // 弹幕滚动区域
            Row.width('100%');
            // 弹幕滚动区域
            Row.height('100%');
            // 弹幕滚动区域
            Row.linearGradient({
                direction: GradientDirection.Right,
                colors: [
                    ['#013C9C', 0.0],
                    ['#3066E4', 0.5],
                    ['#43A1F4', 1.0]
                ]
            });
            // 弹幕滚动区域
            Row.borderRadius(16);
            // 弹幕滚动区域
            Row.justifyContent(FlexAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('欢迎学习鸿蒙开发');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(46:13)", "entry");
            Text.textOverflow({ overflow: TextOverflow.MARQUEE });
            Text.marqueeOptions({
                start: true // 关键：是否启动滚动。true：启动滚动；false：停止滚动
            });
            Text.fontSize(88);
            Text.fontWeight(FontWeight.Regular);
            Text.fontColor('#FFFFFF');
        }, Text);
        Text.pop();
        // 弹幕滚动区域
        Row.pop();
        // 弹幕展示框
        Column.pop();
        // 2. 预览区
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 3. 操作区
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(87:7)", "entry");
            // 3. 操作区
            Column.padding({
                left: 16,
                right: 16
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 弹幕内容区
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(89:9)", "entry");
            // 弹幕内容区
            Column.width('100%');
            // 弹幕内容区
            Column.alignItems(HorizontalAlign.Start);
            // 弹幕内容区
            Column.margin({
                top: 28,
                bottom: 28
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('弹幕内容');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(90:11)", "entry");
            Text.fontSize(14);
            Text.fontColor('#99000000');
            Text.fontWeight(FontWeight.Medium);
            Text.margin({ left: 12 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 输入框
            TextArea.create({ text: '欢迎学习鸿蒙开发' });
            TextArea.debugLine("entry/src/main/ets/pages/Index.ets(97:11)", "entry");
            // 输入框
            TextArea.backgroundColor(Color.White);
            // 输入框
            TextArea.maxLength(50);
            // 输入框
            TextArea.showCounter(true, // 开启统计
            {
                thresholdPercentage: 1,
                highlightBorder: true // 输入快满时，边框会高亮提醒
            });
            // 输入框
            TextArea.height(72);
            // 输入框
            TextArea.padding({
                top: 8,
                right: 16,
                bottom: 8,
                left: 16
            });
            // 输入框
            TextArea.margin({ top: 8 });
            // 输入框
            TextArea.borderRadius(16);
        }, TextArea);
        // 弹幕内容区
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 设置区
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(125:9)", "entry");
            // 设置区
            Column.width('100%');
            // 设置区
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 标题
            Text.create('显示设置');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(127:11)", "entry");
            // 标题
            Text.fontSize(14);
            // 标题
            Text.fontColor('#99000000');
            // 标题
            Text.fontWeight(FontWeight.Medium);
            // 标题
            Text.margin({
                bottom: 8,
                left: 12
            });
        }, Text);
        // 标题
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(136:11)", "entry");
            Column.width('100%');
            Column.padding({
                left: 12,
                right: 12,
                top: 4,
                bottom: 4
            });
            Column.margin({ bottom: 12 });
            Column.backgroundColor(Color.White);
            Column.borderRadius(16);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 字号大小区
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/Index.ets(138:13)", "entry");
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/Index.ets(139:15)", "entry");
            Row.width('100%');
            Row.height(48);
            Row.justifyContent(FlexAlign.SpaceBetween);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('字体大小');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(140:17)", "entry");
            Text.fontSize(16);
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('小');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(143:17)", "entry");
            Text.fontSize(14);
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Slider.create({
                value: 168,
                min: 88,
                max: 248,
                step: 80,
                style: SliderStyle.InSet
            });
            Slider.debugLine("entry/src/main/ets/pages/Index.ets(150:15)", "entry");
            Slider.width('calc(100% + 12vp)');
            Slider.height(40);
            Slider.blockColor(Color.White);
            Slider.trackColor('#F1F3F5');
            Slider.selectedColor('#0A59F7');
            Slider.showSteps(true);
        }, Slider);
        // 字号大小区
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 字体粗细区
            Row.create();
            Row.debugLine("entry/src/main/ets/pages/Index.ets(166:13)", "entry");
            // 字体粗细区
            Row.width('100%');
            // 字体粗细区
            Row.height(48);
            // 字体粗细区
            Row.margin({ top: 12 });
            // 字体粗细区
            Row.justifyContent(FlexAlign.SpaceBetween);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('字体粗细');
            Text.debugLine("entry/src/main/ets/pages/Index.ets(167:15)", "entry");
            Text.fontSize(16);
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Select.create([]);
            Select.debugLine("entry/src/main/ets/pages/Index.ets(170:15)", "entry");
            Select.backgroundColor('#FFFFFF');
            Select.fontColor('#99000000');
            Select.borderWidth(0);
        }, Select);
        Select.pop();
        // 字体粗细区
        Row.pop();
        Column.pop();
        // 设置区
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('显示弹幕');
            Button.debugLine("entry/src/main/ets/pages/Index.ets(195:9)", "entry");
            Button.height(40);
            Button.backgroundColor('#0A59F7');
            Button.margin({ top: 32 });
            Button.width('100%');
        }, Button);
        Button.pop();
        // 3. 操作区
        Column.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.example.led", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
