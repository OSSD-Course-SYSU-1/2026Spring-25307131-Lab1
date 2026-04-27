# WindowOrientation 项目完整代码解析

## 📋 项目概览

**项目名称**: WindowOrientation  
**包名**: com.example.windoworientation  
**版本**: 1.0.0  
**项目类型**: HarmonyOS窗口方向控制示例应用  
**支持设备**: Phone、Tablet

---

## 🏗️ 项目架构

### 目录结构
```
WindowOrientation-master/
├── AppScope/                    # 应用全局配置
├── commons/                     # 公共模块
│   └── base/                   # 基础公共库
├── features/                    # 功能特性模块
│   ├── home/                   # 主页模块
│   ├── portrait/               # 竖屏模式
│   ├── landscape/              # 横屏模式
│   ├── photos/                 # 照片模块
│   ├── stock/                  # 股票模块
│   └── video/                  # 视频模块
└── products/                    # 产品入口
    └── default/                # 默认产品配置
```

---

## 🔑 核心文件解析

### 1. 应用入口 - EntryAbility.ets

**路径**: `products/default/src/main/ets/entryability/EntryAbility.ets`

```typescript
export default class EntryAbility extends UIAbility {
  uiContext?: UIContext;
  onWindowSizeChange: (windowSize: window.Size) => void = () => {
    let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
    AppStorage.setOrCreate(CommonConstants.WIDTH_BREAK_POINT, widthBp);
    let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
    AppStorage.setOrCreate(CommonConstants.HEIGHT_BREAK_POINT, heightBp);
  }
}
```

**关键功能**:
- ✅ **窗口尺寸监听**: 实时监听窗口大小变化
- ✅ **断点系统**: 自动计算宽度/高度断点（WIDTH_SM/MD/LG, HEIGHT_SM/MD/LG）
- ✅ **全局状态管理**: 使用AppStorage存储断点信息供全局使用
- ✅ **UIContext获取**: 获取UI上下文用于窗口操作

**生命周期流程**:
```
onCreate → onWindowStageCreate → loadContent('pages/Index') 
         → getMainWindow → 获取UIContext 
         → 设置初始断点 → 注册windowSizeChange监听
```

---

### 2. 主页面 - Index.ets

**路径**: `products/default/src/main/ets/pages/Index.ets`

```typescript
@Entry
@Component
struct Index {
  @StorageLink(CommonConstants.WIDTH_BREAK_POINT) widthBp: WidthBreakpoint = WidthBreakpoint.WIDTH_SM;
  pathStack: NavPathStack = new NavPathStack();
  private cardList: CardListModel[] = [];

  aboutToAppear(): void {
    this.cardList = new CardListViewModel().getCardList()
  }
}
```

**UI结构**:
```
Navigation (Stack模式)
└── List (卡片列表)
    └── ForEach (cardList)
        └── ListItem
            └── ListItemCard (自定义卡片组件)
                ├── Column (标题 + 描述)
                └── Image (右箭头图标)
```

**功能特点**:
- 🎯 **导航栈管理**: 使用NavPathStack管理页面导航
- 📱 **响应式布局**: 通过断点系统适配不同屏幕尺寸
- 🎨 **卡片式UI**: 每个功能模块以卡片形式展示
- 🔗 **安全区域扩展**: `expandSafeArea([SafeAreaType.SYSTEM])`

---

### 3. 数据模型 - CardListModel & CardListViewModel

**CardListModel**:
```typescript
export class CardListModel {
  title: ResourceStr = '';      // 卡片标题（支持国际化）
  desc: string = '';            // 描述文本
  pathName: string = '';        // 导航路径名称
}
```

**CardListViewModel** - 初始化六个功能模块:
```typescript
initCardList() {
  this.cardList.push(new CardListModel($r("app.string.homepage"), 'FOLLOW_DESKTOP', 'Home'))
  this.cardList.push(new CardListModel($r("app.string.portrait_mode_game"), 'PORTRAIT', 'PortraitModeGame'))
  this.cardList.push(new CardListModel($r("app.string.landscape_mode_game"), 'LANDSCAPE', 'LandscapeModeGame'))
  this.cardList.push(new CardListModel($r("app.string.photos"), 'AUTO_ROTATION_UNSPECIFIED', 'Photos'))
  this.cardList.push(new CardListModel($r("app.string.stock"), 'FOLLOW_DESKTOP', 'StockDetail'))
  this.cardList.push(new CardListModel($r("app.string.video"), 'AUTO_ROTATION_LANDSCAPE_RESTRICTED', 'VideoDetail'))
}
```

---

## 🎮 功能模块详解

### 1. 主页模块 (Home)

**窗口方向**: `FOLLOW_DESKTOP` (跟随桌面方向)

**核心代码**:
```typescript
aboutToAppear(): void {
  this.windowObj?.setPreferredOrientation(window.Orientation.FOLLOW_DESKTOP)
}

aboutToDisappear() {
  this.windowObj?.setPreferredOrientation(window.Orientation.UNSPECIFIED)
}
```

**UI特点**:
- 🌊 **瀑布流布局**: WaterFlow组件，自适应列数
- 📊 **断点响应**: `PresetFillType.BREAKPOINT_SM2MD3LG5`
  - SM (小屏): 2列
  - MD (中屏): 3列
  - LG (大屏): 5列
- 🔄 **懒加载**: LazyForEach + cachedCount(2)
- 📑 **标签栏**: 底部/侧边自适应

---

### 2. 竖屏模式 (PortraitModeGame)

**窗口方向**: `PORTRAIT` (强制竖屏)

**功能演示**:
```typescript
aboutToAppear(): void {
  this.windowObj?.setPreferredOrientation(window.Orientation.PORTRAIT)
}
```

**UI特点**:
- 🎲 **8x8网格**: 游戏方块布局
- 🎨 **随机颜色**: 3种预设颜色随机分配
- 📱 **固定竖屏**: 不响应设备旋转

---

### 3. 横屏模式 (LandscapeModeGame)

**窗口方向**: `LANDSCAPE` (强制横屏)

**UI布局**:
```typescript
Row({ space: 10 }) {
  Row().width(128).aspectRatio(1).borderRadius('50%')  // 圆形1
  Row().width(128).aspectRatio(1).borderRadius('50%')  // 圆形2
}
.justifyContent(FlexAlign.SpaceBetween)
.alignItems(VerticalAlign.Bottom)
```

**特点**:
- 🖥️ **强制横屏**: 适合游戏、视频场景
- ⭕ **双圆形UI**: 演示横屏布局优势

---

### 4. 照片模块 (Photos)

**窗口方向**: `AUTO_ROTATION_UNSPECIFIED` (自动旋转)

**核心特性**:
```typescript
@Builder
ReusableListItem(params: number) {
  Image($r(`app.media.ic_photos_${params % 7}`))  // 7张图片循环
    .width(CommonConstants.FULL_PERCENT)
    .aspectRatio(1)
    .objectFit(ImageFit.Cover)
}
```

**布局**:
- 📸 **4列网格**: `lanes(4, 2)`
- 🔄 **懒加载**: LazyForEach优化性能
- 📱 **自适应Tab栏**: 大屏侧边，小屏底部

---

### 5. 股票模块 (StockDetail)

**窗口方向**: `FOLLOW_DESKTOP`

**复杂UI结构**:
```
NavDestination
├── Stack (标题栏)
│   ├── Row (返回按钮)
│   └── Column (股票信息)
├── Scroll (图表区域)
│   ├── LineChart (折线图)
│   └── BarChartView (柱状图)
└── StockDealDetails (交易详情)
```

**特点**:
- 📈 **图表集成**: 使用@ohos/mpchart库
- 📊 **多图表类型**: 折线图 + 柱状图
- 🎯 **可展开面板**: `@Provide('isExpand')`

---

### 6. 视频模块 (VideoDetail)

**窗口方向**: `AUTO_ROTATION_LANDSCAPE_RESTRICTED` (横屏受限自动旋转)

**核心逻辑**:
```typescript
@StorageLink('isFullScreen') @Watch('onFullScreenChange') isFullScreen: boolean = false;

onFullScreenChange(): void {
  if (this.isFullScreen) {
    if (this.widthBp === WidthBreakpoint.WIDTH_SM || 
        this.widthBp === WidthBreakpoint.WIDTH_LG ||
        this.heightBp === HeightBreakpoint.HEIGHT_LG) {
      this.windowObj?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED)
    }
  }
}
```

**特点**:
- 🎬 **全屏控制**: 根据断点动态调整方向
- 📺 **视频播放器**: AvPlayerUtil集成
- 💬 **评论区**: AllComments组件
- 🎥 **相关视频**: RelatedList组件

---

## 🛠️ 工具类解析

### Logger.ets
```typescript
class Logger {
  private domain: number = 0xFF00;
  private prefix: string;
  
  debug(...args: string[]): void { hilog.debug(this.domain, this.prefix, this.format, args); }
  info(...args: string[]): void { hilog.info(this.domain, this.prefix, this.format, args); }
  warn(...args: string[]): void { hilog.warn(this.domain, this.prefix, this.format, args); }
  error(...args: string[]): void { hilog.error(this.domain, this.prefix, this.format, args); }
}
```

**用途**: 统一日志管理，封装hilog API

---

### CommonConstants.ets
```typescript
export class CommonConstants {
  static readonly FULL_PERCENT: string = '100%';
  static readonly HALF_PERCENT: string = '50%';
  static readonly WIDTH_BREAK_POINT: string = 'widthBreakPoint';
  static readonly HEIGHT_BREAK_POINT: string = 'heightBreakPoint';
  static readonly AV_PLAYER_PLAYING_STATE: string = 'playing';
  // ... 更多常量
}
```

**设计模式**: 常量集中管理，避免魔法值

---

## ⚙️ 配置文件解析

### module.json5
```json5
{
  "module": {
    "name": "default",
    "type": "entry",
    "deviceTypes": ["phone", "tablet"],
    "abilities": [{
      "name": "EntryAbility",
      "orientation": "unspecified",  // 初始方向不指定
      "skills": [{
        "entities": ["entity.system.home"],
        "actions": ["ohos.want.action.home"]
      }]
    }]
  }
}
```

### main_pages.json
```json
{
  "src": ["pages/Index"]
}
```

---

## 🎯 核心技术点总结

### 1. 窗口方向控制
| 方向类型 | 说明 | 使用场景 |
|---------|------|---------|
| `FOLLOW_DESKTOP` | 跟随桌面 | 默认应用 |
| `PORTRAIT` | 强制竖屏 | 游戏、表单 |
| `LANDSCAPE` | 强制横屏 | 游戏、视频 |
| `AUTO_ROTATION_UNSPECIFIED` | 自动旋转 | 照片浏览 |
| `AUTO_ROTATION_LANDSCAPE_RESTRICTED` | 横屏受限 | 视频播放 |
| `UNSPECIFIED` | 不指定 | 退出时恢复 |

### 2. 响应式设计
- **断点系统**: WIDTH_SM/MD/LG, HEIGHT_SM/MD/LG
- **状态同步**: `@StorageLink` 实现全局状态
- **动态布局**: 根据断点调整UI结构

### 3. 性能优化
- ✅ **懒加载**: LazyForEach替代ForEach
- ✅ **缓存**: cachedCount预加载
- ✅ **组件复用**: @Builder函数
- ✅ **按需加载**: aboutToAppear/aboutToDisappear生命周期管理

### 4. 导航架构
```
Navigation (Stack模式)
├── NavPathStack (路径栈管理)
└── NavDestination (目标页面)
    └── pushPathByName() (路由跳转)
```

---

## 📊 状态管理架构

```
AppStorage (全局状态)
├── widthBreakPoint (宽度断点)
├── heightBreakPoint (高度断点)
├── isFullScreen (全屏状态)
├── avplayerState (播放器状态)
└── isClick (点击状态)
     ↓
@StorageLink (组件内双向绑定)
```

---

## 🔄 完整运行流程

```
1. 应用启动
   └─> EntryAbility.onCreate()
       └─> onWindowStageCreate()
           └─> loadContent('pages/Index')
               └─> 获取主窗口
                   └─> 初始化UIContext
                       └─> 计算初始断点
                           └─> 注册窗口尺寸监听

2. 主页加载
   └─> Index.aboutToAppear()
       └─> CardListViewModel.getCardList()
           └─> 渲染卡片列表
               └─> 用户点击卡片
                   └─> pathStack.pushPathByName()

3. 功能模块加载
   └─> [Module].aboutToAppear()
       └─> 获取窗口对象
           └─> setPreferredOrientation()
               └─> 设置指定方向
                   └─> 渲染模块UI

4. 窗口尺寸变化
   └─> onWindowSizeChange回调
       └─> 重新计算断点
           └─> 更新AppStorage
               └─> 触发@StorageLink组件更新
                   └─> UI自适应调整

5. 模块退出
   └─> [Module].aboutToDisappear()
       └─> setPreferredOrientation(UNSPECIFIED)
           └─> 恢复默认方向
```

---

## 💡 设计亮点

1. **模块化架构**: features独立模块，commons共享基础
2. **响应式设计**: 完整的断点系统和自适应布局
3. **生命周期管理**: 规范的方向设置和清理
4. **性能优化**: 懒加载、缓存、组件复用
5. **错误处理**: 完善的try-catch和错误日志
6. **国际化支持**: 使用ResourceStr和$r()引用资源

---

## 📝 模块功能对照表

| 模块名称 | 路由名称 | 窗口方向 | 主要功能 |
|---------|---------|---------|---------|
| 主页 | Home | FOLLOW_DESKTOP | 瀑布流展示、标签导航 |
| 竖屏游戏 | PortraitModeGame | PORTRAIT | 8x8网格游戏布局 |
| 横屏游戏 | LandscapeModeGame | LANDSCAPE | 双圆形横屏布局 |
| 照片 | Photos | AUTO_ROTATION_UNSPECIFIED | 4列照片网格 |
| 股票 | StockDetail | FOLLOW_DESKTOP | 图表展示、交易详情 |
| 视频 | VideoDetail | AUTO_ROTATION_LANDSCAPE_RESTRICTED | 视频播放、评论互动 |

---

## 🔧 开发建议

### 扩展新模块步骤

1. **创建模块目录**
   ```
   features/newmodule/
   ├── src/main/ets/
   │   └── views/NewModule.ets
   ├── Index.ets
   └── module.json5
   ```

2. **实现窗口方向控制**
   ```typescript
   aboutToAppear(): void {
     this.windowObj = (this.getUIContext().getHostContext() as common.UIAbilityContext)
       .windowStage.getMainWindowSync()
     this.windowObj?.setPreferredOrientation(window.Orientation.YOUR_ORIENTATION)
   }
   
   aboutToDisappear() {
     this.windowObj?.setPreferredOrientation(window.Orientation.UNSPECIFIED)
   }
   ```

3. **注册到主页**
   ```typescript
   // CardListViewModel.ets
   this.cardList.push(new CardListModel(
     $r("app.string.new_module"),
     'ORIENTATION_TYPE',
     'NewModule'
   ))
   ```

4. **配置路由**
   ```typescript
   // Index.ets
   @Builder
   export function NewModuleBuilder() {
     NewModule()
   }
   ```

---

## 📚 相关文档

- [HarmonyOS窗口管理开发指导](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/application-window-stage-0000001100901385)
- [窗口方向设置API参考](https://developer.harmonyos.com/cn/docs/documentation/doc-references/js-apis-window-0000001478341282)
- [响应式布局开发指导](https://developer.harmonyos.com/cn/docs/documentation/doc-guides/arkts-layout-development-create-responsive-layout-0000001333766905)

---

**文档生成时间**: 2026-04-21  
**项目版本**: 1.0.0  
**HarmonyOS API版本**: API 11+
