/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Settings, SettingsRecord, DisplayArea, DisplayMode } from '../model/Settings';
import { ThemeManager, ThemeConfig } from '../utils/ThemeManager';
import { PresetTemplates, PresetTemplate } from '../utils/PresetTemplates';
import { KeywordFilter } from '../utils/KeywordFilter';
import { HistoryManager, HistoryItem } from '../utils/HistoryManager';
import { StatsManager } from '../utils/StatsManager';
import { common } from '@kit.AbilityKit';


const CONTINUE_KEY = 'continueSettings';

const DANMAKU_COLORS: string[] = [
  '#FFFFFF', '#FFF176', '#FFD740', '#FFB74D',
  '#FF8A80', '#FF5252', '#F48FB1', '#E040FB',
  '#7C4DFF', '#448AFF', '#40C4FF', '#80D8FF',
  '#64FFDA', '#69F0AE', '#B2FF59', '#FF6E40'
];

@Entry
@ComponentV2
struct Index {
  @Local content: string = '欢迎学习鸿蒙开发';
  @Local fontSize: number = 88;
  @Local fontSizeFlag: string = '小';
  @Local fontWeight: FontWeight = FontWeight.Regular;
  @Local selectedIndex: number = 0;
  fontWeights: FontWeight[] = [FontWeight.Regular, FontWeight.Medium, FontWeight.Bold];

  @Local fontColor: string = '#FFFFFF';
  @Local selectedColorIndex: number = 0;
  @Local speed: number = 6;
  @Local speedFlag: string = '中';
  @Local displayArea: DisplayArea = DisplayArea.CENTER;
  @Local displayAreaIndex: number = 1;
  @Local displayMode: DisplayMode = DisplayMode.SLIDE;
  @Local displayModeIndex: number = 0;
  @Local themeName: string = '默认蓝';
  @Local themeIndex: number = 0;

  @Local filterKeyword: string = '';
  @Local filteredContent: string = '';

  @Local showPresetPanel: boolean = false;
  @Local showKeywordPanel: boolean = false;
  @Local keywordList: string[] = [];

  @Local showColorPicker: boolean = false;

  pathInfos: NavPathStack = new NavPathStack();

  keywordFilter: KeywordFilter = new KeywordFilter();
  historyManager: HistoryManager = new HistoryManager();
  statsManager: StatsManager = new StatsManager();
  @Local isManagersReady: boolean = false;

  @Local currentBreakpoint: string = 'sm';

  private titleFontSize(): number {
    if (this.currentBreakpoint === 'lg') return 34;
    if (this.currentBreakpoint === 'md') return 30;
    return 26;
  }

  private sectionLabelFontSize(): number {
    if (this.currentBreakpoint === 'lg') return 16;
    if (this.currentBreakpoint === 'md') return 15;
    return 14;
  }

  private settingLabelFontSize(): number {
    if (this.currentBreakpoint === 'lg') return 18;
    if (this.currentBreakpoint === 'md') return 17;
    return 16;
  }

  private btnHeight(): number {
    return this.currentBreakpoint === 'sm' ? 44 : 48;
  }

  private previewHeight(): number {
    if (this.currentBreakpoint === 'lg') return 360;
    if (this.currentBreakpoint === 'md') return 280;
    return 199;
  }

  aboutToAppear(): void {
    const context = this.getUIContext().getHostContext() as common.Context;
    this.initManagers(context);
    this.restoreFromContinue();
  }

  private restoreFromContinue(): void {
    const settingsStr = AppStorage.get<string>(CONTINUE_KEY);
    if (settingsStr && settingsStr.length > 0) {
      try {
        const record = JSON.parse(settingsStr) as SettingsRecord;
        const settings = Settings.fromRecord(record);
        AppStorage.delete(CONTINUE_KEY);
        setTimeout(() => {
          this.pathInfos.pushPathByName('Led', settings);
        }, 300);
      } catch (e) {
        AppStorage.delete(CONTINUE_KEY);
      }
    }
  }

  private async initManagers(context: common.Context): Promise<void> {
    await Promise.all([
      this.keywordFilter.init(context),
      this.historyManager.init(context),
      this.statsManager.init(context)
    ]);
    this.keywordList = await this.keywordFilter.getKeywords();
    this.isManagersReady = true;
  }

  private getThemeBgColors(): string[] {
    return ThemeManager.getThemeByName(this.themeName).bgColors;
  }

  private getPreviewAlign(): FlexAlign {
    if (this.displayArea === DisplayArea.TOP) {
      return FlexAlign.Start;
    } else if (this.displayArea === DisplayArea.BOTTOM) {
      return FlexAlign.End;
    }
    return FlexAlign.Center;
  }

  private handleDisplayAreaChange(index: number): void {
    this.displayAreaIndex = index;
    const areas = [DisplayArea.TOP, DisplayArea.CENTER, DisplayArea.BOTTOM];
    this.displayArea = areas[index];
  }

  private handleThemeChange(index: number): void {
    this.themeIndex = index;
    const names = ThemeManager.getAllThemeNames();
    this.themeName = names[index];
    const theme = ThemeManager.getThemeByName(this.themeName);
    this.fontColor = theme.defaultFontColor;
    this.selectedColorIndex = DANMAKU_COLORS.indexOf(theme.defaultFontColor);
  }

  private handleSpeedChange(value: number): void {
    this.speed = value;
    if (this.speed <= 3) {
      this.speedFlag = '慢';
    } else if (this.speed >= 9) {
      this.speedFlag = '快';
    } else {
      this.speedFlag = '中';
    }
  }

  private applyPreset(template: PresetTemplate): void {
    this.content = template.content;
    this.showPresetPanel = false;
  }

  private async addKeyword(): Promise<void> {
    if (this.filterKeyword.trim().length === 0) {
      return;
    }
    await this.keywordFilter.addKeyword(this.filterKeyword.trim());
    this.keywordList = await this.keywordFilter.getKeywords();
    this.filterKeyword = '';
  }

  private async removeKeyword(keyword: string): Promise<void> {
    await this.keywordFilter.removeKeyword(keyword);
    this.keywordList = await this.keywordFilter.getKeywords();
  }

  private async onSendDanmu(): Promise<void> {
    let finalContent = this.content;
    if (this.keywordList.length > 0) {
      finalContent = this.keywordFilter.filterContent(this.content);
    }

    const settings = new Settings(
      finalContent,
      this.fontSize,
      this.fontWeight,
      this.fontColor,
      this.speed,
      this.displayArea,
      this.displayMode,
      this.getThemeBgColors(),
      this.themeName
    );

    AppStorage.setOrCreate<string>(CONTINUE_KEY, JSON.stringify(settings.toRecord()));

    if (this.isManagersReady) {
      const historyItem: HistoryItem = {
        content: this.content,
        timestamp: Date.now(),
        fontColor: this.fontColor
      };
      await this.historyManager.addHistory(historyItem);
      await this.statsManager.recordSend();
    }

    this.pathInfos.pushPathByName('Led', settings);
  }

  @Builder
  buildSectionHeader(title: string) {
    Text(title)
      .fontSize(this.sectionLabelFontSize())
      .fontColor('#5F6368')
      .fontWeight(FontWeight.Medium)
      .margin({ left: 12, bottom: 8 })
  }

  @Builder
  buildPreviewArea() {
    Column() {
      Text('预览')
        .fontSize(this.sectionLabelFontSize())
        .fontColor('#5F6368')
        .fontWeight(FontWeight.Medium)
        .margin({ left: 28 })

      Column() {
        Row() {
          if (this.displayMode === DisplayMode.SLIDE) {
            Text(this.content)
              .textOverflow({ overflow: TextOverflow.MARQUEE })
              .marqueeOptions({ start: true, step: this.speed })
              .fontSize(this.fontSize / 1.8)
              .fontWeight(this.fontWeight)
              .fontColor(this.fontColor)
              .shadow({
                radius: 4,
                color: 'rgba(0, 0, 0, 0.4)',
                offsetX: 1,
                offsetY: 1
              })
          } else {
            Text(this.content)
              .fontSize(this.fontSize / 1.8)
              .fontWeight(this.fontWeight)
              .fontColor(this.fontColor)
              .textAlign(TextAlign.Center)
              .shadow({
                radius: 4,
                color: 'rgba(0, 0, 0, 0.4)',
                offsetX: 1,
                offsetY: 1
              })
          }
        }
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [
            [this.getThemeBgColors()[0], 0.0],
            [this.getThemeBgColors()[1], 0.5],
            [this.getThemeBgColors()[2], 1.0]
          ]
        })
        .borderRadius(16)
        .justifyContent(this.getPreviewAlign())
      }
      .width('100%')
      .height(this.previewHeight())
      .backgroundColor('rgba(255,255,255,0.9)')
      .border({ width: 1, color: 'rgba(0,0,0,0.06)' })
      .padding({ top: 24, right: 16, bottom: 24, left: 16 })
      .margin({ top: 8 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .margin({ top: 28 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildSettingsArea() {
    Scroll() {
      Column() {
        Column() {
          Text('弹幕内容')
            .fontSize(this.sectionLabelFontSize())
            .fontColor('#5F6368')
            .fontWeight(FontWeight.Medium)
            .margin({ left: 12 })

          TextArea({ text: this.content })
            .backgroundColor(Color.White)
            .fontColor('#1A1C1E')
            .maxLength(50)
            .showCounter(true, { thresholdPercentage: 1, highlightBorder: true })
            .height(72)
            .padding({ top: 8, right: 16, bottom: 8, left: 16 })
            .margin({ top: 8 })
            .borderRadius(16)
            .border({ width: 1, color: 'rgba(0,0,0,0.08)' })
            .onChange((value: string) => {
              this.content = value;
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 28, bottom: 12 })

        Row() {
          Button('预设模板')
            .fontSize(13)
            .height(this.btnHeight())
            .backgroundColor('rgba(0,0,0,0.04)')
            .fontColor('#3C4043')
            .border({ width: 1, color: 'rgba(0,0,0,0.08)' })
            .borderRadius(12)
            .onClick(() => { this.showPresetPanel = !this.showPresetPanel; })
          Button('关键词过滤')
            .fontSize(13)
            .height(this.btnHeight())
            .backgroundColor('rgba(0,0,0,0.04)')
            .fontColor('#3C4043')
            .border({ width: 1, color: 'rgba(0,0,0,0.08)' })
            .borderRadius(12)
            .onClick(() => { this.showKeywordPanel = !this.showKeywordPanel; })
          Button('历史记录')
            .fontSize(13)
            .height(this.btnHeight())
            .backgroundColor('rgba(0,0,0,0.04)')
            .fontColor('#3C4043')
            .border({ width: 1, color: 'rgba(0,0,0,0.08)' })
            .borderRadius(12)
            .onClick(() => { this.pathInfos.pushPathByName('History', null); })
          Button('统计面板')
            .fontSize(13)
            .height(this.btnHeight())
            .backgroundColor('rgba(0,0,0,0.04)')
            .fontColor('#3C4043')
            .border({ width: 1, color: 'rgba(0,0,0,0.08)' })
            .borderRadius(12)
            .onClick(() => { this.pathInfos.pushPathByName('Stats', null); })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ top: 8, bottom: 12 })

        if (this.showPresetPanel) {
          Column() {
            Text('预设模板库')
              .fontSize(this.sectionLabelFontSize())
              .fontColor('#5F6368')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 12, top: 8 })

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(PresetTemplates.getAll(), (template: PresetTemplate) => {
                Button(template.label)
                  .fontSize(this.sectionLabelFontSize())
                  .height(this.btnHeight())
                  .margin(4)
                  .backgroundColor('rgba(0,0,0,0.04)')
                  .fontColor('#3C4043')
                  .border({ width: 1, color: 'rgba(0,0,0,0.08)' })
                  .onClick(() => { this.applyPreset(template); })
              }, (template: PresetTemplate) => template.label)
            }
            .width('100%')
            .padding({ left: 12, right: 12, top: 8, bottom: 12 })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .border({ width: 1, color: 'rgba(0,0,0,0.06)' })
          .borderRadius(16)
          .margin({ bottom: 12 })
        }

        if (this.showKeywordPanel) {
          Column() {
            Text('关键词过滤')
              .fontSize(this.sectionLabelFontSize())
              .fontColor('#5F6368')
              .fontWeight(FontWeight.Medium)
              .margin({ left: 12, top: 8, bottom: 8 })

            Row() {
              TextInput({ text: this.filterKeyword, placeholder: '输入过滤关键词' })
                .layoutWeight(1)
                .height(this.btnHeight())
                .backgroundColor('rgba(0,0,0,0.03)')
                .borderRadius(8)
                .onChange((value: string) => { this.filterKeyword = value; })
              Button('添加')
                .fontSize(13)
                .height(this.btnHeight())
                .backgroundColor('#0A59F7')
                .fontColor('#FFFFFF')
                .borderRadius(12)
                .margin({ left: 8 })
                .onClick(() => { this.addKeyword(); })
            }
            .width('100%')
            .padding({ left: 12, right: 12 })
            .margin({ bottom: 8 })

            if (this.keywordList.length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.keywordList, (keyword: string) => {
                  Row() {
                    Text(keyword)
                      .fontSize(13)
                      .fontColor('#3C4043')
                      .margin({ right: 4 })
                    Text('×')
                      .fontSize(13)
                      .fontColor('#999999')
                      .onClick(() => { this.removeKeyword(keyword); })
                  }
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .margin(4)
                  .backgroundColor('rgba(0,0,0,0.04)')
                  .border({ width: 1, color: 'rgba(0,0,0,0.08)' })
                  .borderRadius(12)
                }, (keyword: string) => keyword)
              }
              .width('100%')
              .padding({ left: 12, right: 12, bottom: 12 })
            }
          }
          .width('100%')
          .backgroundColor(Color.White)
          .border({ width: 1, color: 'rgba(0,0,0,0.06)' })
          .borderRadius(16)
          .margin({ bottom: 12 })
        }

        Column() {
          this.buildSectionHeader('显示设置');

          Column() {
            Column() {
              Row() {
                Text('字体大小')
                  .fontSize(this.settingLabelFontSize())
                  .fontWeight(FontWeight.Medium)
                Text(this.fontSizeFlag)
                  .fontSize(this.sectionLabelFontSize())
              }
              .width('100%')
              .height(this.btnHeight())
              .justifyContent(FlexAlign.SpaceBetween)

              Slider({
                value: this.fontSize,
                min: 88,
                max: 248,
                step: 80,
                style: SliderStyle.InSet
              })
                .width('calc(100% + 12vp)')
                .height(this.btnHeight())
                .blockColor('#5F6368')
                .trackColor('rgba(0,0,0,0.06)')
                .selectedColor('#0A59F7')
                .showSteps(true)
                .onChange((value: number) => {
                  this.fontSize = value;
                  if (this.fontSize === 88) {
                    this.fontSizeFlag = '小';
                  } else if (this.fontSize === 248) {
                    this.fontSizeFlag = '大';
                  } else {
                    this.fontSizeFlag = '中';
                  }
                })
            }

            Row() {
              Text('字体粗细')
                .fontSize(this.settingLabelFontSize())
                .fontWeight(FontWeight.Medium)
              Select([
                { value: this.fontWeights[0].toString() },
                { value: this.fontWeights[1].toString() },
                { value: this.fontWeights[2].toString() }
              ])
                .value(this.fontWeight.toString())
                .selected(this.selectedIndex)
                .backgroundColor(Color.White)
                .fontColor('#5F6368')
                .borderWidth(0)
                .onSelect((index: number) => {
                  this.fontWeight = this.fontWeights[index];
                  this.selectedIndex = index;
                })
            }
            .width('100%')
            .height(this.btnHeight())
            .margin({ top: 12 })
            .justifyContent(FlexAlign.SpaceBetween)

            if (this.displayMode === DisplayMode.SLIDE) {
              Row() {
                Text('弹幕速度')
                  .fontSize(this.settingLabelFontSize())
                  .fontWeight(FontWeight.Medium)
                Text(this.speedFlag)
                  .fontSize(this.sectionLabelFontSize())
              }
              .width('100%')
              .height(this.btnHeight())
              .margin({ top: 12 })
              .justifyContent(FlexAlign.SpaceBetween)

              Slider({
                value: this.speed,
                min: 1,
                max: 12,
                step: 1,
                style: SliderStyle.InSet
              })
                .width('calc(100% + 12vp)')
                .height(this.btnHeight())
                .blockColor('#5F6368')
                .trackColor('rgba(0,0,0,0.06)')
                .selectedColor('#0A59F7')
                .onChange((value: number) => {
                  this.handleSpeedChange(value);
                })
            }

            Row() {
              Text('弹幕颜色')
                .fontSize(this.settingLabelFontSize())
                .fontWeight(FontWeight.Medium)
              Row() {
                Circle()
                  .width(32)
                  .height(32)
                  .fill(this.fontColor)
                  .border({ width: 2, color: '#CCCCCC' })
                  .shadow({ radius: 4, color: 'rgba(0,0,0,0.15)', offsetX: 0, offsetY: 2 })
              }
            }
            .width('100%')
            .height(this.btnHeight())
            .margin({ top: 12 })
            .justifyContent(FlexAlign.SpaceBetween)

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(DANMAKU_COLORS, (color: string, index: number) => {
                Column() {
                  Circle()
                    .width(this.currentBreakpoint === 'sm' ? 36 : 40)
                    .height(this.currentBreakpoint === 'sm' ? 36 : 40)
                    .fill(color)
                    .border({
                      width: index === this.selectedColorIndex ? 3 : 1,
                      color: index === this.selectedColorIndex ? '#0A59F7' : '#DDDDDD'
                    })
                    .shadow({
                      radius: index === this.selectedColorIndex ? 6 : 2,
                      color: 'rgba(0,0,0,0.2)',
                      offsetX: 0,
                      offsetY: 2
                    })
                }
                .margin(4)
                .onClick(() => {
                  this.fontColor = color;
                  this.selectedColorIndex = index;
                })
              }, (color: string, index: number) => `${color}_${index}`)
            }
            .width('100%')
            .margin({ top: 4, bottom: 4 })
            .padding({ left: 4, right: 4 })

            Row() {
              TextInput({ text: this.fontColor, placeholder: '#自定义颜色' })
                .layoutWeight(1)
                .height(this.currentBreakpoint === 'sm' ? 32 : 36)
                .fontSize(12)
                .borderRadius(8)
                .onChange((value: string) => {
                  if (value.startsWith('#') && value.length === 7) {
                    this.fontColor = value;
                    this.selectedColorIndex = -1;
                  }
                })
            }
            .width('100%')
            .margin({ top: 4 })
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text('显示方式')
                .fontSize(this.settingLabelFontSize())
                .fontWeight(FontWeight.Medium)
              Select([
                { value: '滑动弹幕' },
                { value: '滞留弹幕' }
              ])
                .value(this.displayModeIndex === 0 ? '滑动弹幕' : '滞留弹幕')
                .selected(this.displayModeIndex)
                .backgroundColor(Color.White)
                .fontColor('#5F6368')
                .borderWidth(0)
                .onSelect((index: number) => {
                  this.displayModeIndex = index;
                  const modes = [DisplayMode.SLIDE, DisplayMode.STATIC];
                  this.displayMode = modes[index];
                })
            }
            .width('100%')
            .height(this.btnHeight())
            .margin({ top: 12 })
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text('显示区域')
                .fontSize(this.settingLabelFontSize())
                .fontWeight(FontWeight.Medium)
              Select([
                { value: '上方' },
                { value: '居中' },
                { value: '下方' }
              ])
                .value(this.displayAreaIndex === 0 ? '上方' : this.displayAreaIndex === 1 ? '居中' : '下方')
                .selected(this.displayAreaIndex)
                .backgroundColor(Color.White)
                .fontColor('#5F6368')
                .borderWidth(0)
                .onSelect((index: number) => {
                  this.handleDisplayAreaChange(index);
                })
            }
            .width('100%')
            .height(this.btnHeight())
            .margin({ top: 12 })
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text('弹幕主题')
                .fontSize(this.settingLabelFontSize())
                .fontWeight(FontWeight.Medium)
              Select(ThemeManager.getAllThemeNames().map((name: string): SelectOption => { return { value: name }; }))
                .value(this.themeName)
                .selected(this.themeIndex)
                .backgroundColor(Color.White)
                .fontColor('#5F6368')
                .borderWidth(0)
                .onSelect((index: number) => {
                  this.handleThemeChange(index);
                })
            }
            .width('100%')
            .height(this.btnHeight())
            .margin({ top: 12 })
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .margin({ bottom: 12 })
          .backgroundColor(Color.White)
          .border({ width: 1, color: 'rgba(0,0,0,0.06)' })
          .borderRadius(16)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Button('显示弹幕')
          .height(Math.max(this.btnHeight(), 48))
          .backgroundColor('#0A59F7')
          .fontColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 12, color: 'rgba(10,89,247,0.35)', offsetX: 0, offsetY: 4 })
          .margin({ top: 32, bottom: 32 })
          .width('100%')
          .onClick(() => { this.onSendDanmu(); })
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  build() {
    Navigation(this.pathInfos) {
      Column() {
        Text('手持弹幕')
          .fontSize(this.titleFontSize())
          .fontColor('#1A1C1E')
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
          .height(this.btnHeight() + 12)
          .shadow({ radius: 8, color: 'rgba(30,111,255,0.15)', offsetX: 0, offsetY: 0 })

        GridRow({
          columns: {
            sm: 1,
            md: 2,
            lg: 2
          },
          gutter: { x: 16 },
          breakpoints: { value: ['600vp', '840vp'] }
        }) {
          GridCol({ span: { sm: 1, md: 1, lg: 1 } }) {
            this.buildPreviewArea()
          }

          GridCol({ span: { sm: 1, md: 1, lg: 1 } }) {
            this.buildSettingsArea()
          }
        }
        .onBreakpointChange((breakpoint: string) => {
          this.currentBreakpoint = breakpoint;
        })
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#E8EDF2')
      .alignItems(HorizontalAlign.Start)
    }
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
  }
}
