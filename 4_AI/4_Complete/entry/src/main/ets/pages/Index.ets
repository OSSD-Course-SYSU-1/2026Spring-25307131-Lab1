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
import { Context } from '@kit.AbilityKit';

const CONTINUE_KEY = 'continueSettings';

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

  aboutToAppear(): void {
    const context = getContext(this) as Context;
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

  private async initManagers(context: Context): Promise<void> {
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
      .fontSize(14)
      .fontColor('#99000000')
      .fontWeight(FontWeight.Medium)
      .margin({ left: 12, bottom: 8 })
  }

  build() {
    Navigation(this.pathInfos) {
      Column() {
        Text('手持弹幕')
          .fontSize(26)
          .fontColor('#000000')
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
          .height(56)

        Column() {
          Text('预览')
            .fontSize(14)
            .fontColor('#99000000')
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
              } else {
                Text(this.content)
                  .fontSize(this.fontSize / 1.8)
                  .fontWeight(this.fontWeight)
                  .fontColor(this.fontColor)
                  .textAlign(TextAlign.Center)
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
          .height(199)
          .backgroundColor('#E5E5EA')
          .padding({ top: 24, right: 16, bottom: 24, left: 16 })
          .margin({ top: 8 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .margin({ top: 28 })
        .alignItems(HorizontalAlign.Start)

        Scroll() {
          Column() {
            Column() {
              Text('弹幕内容')
                .fontSize(14)
                .fontColor('#99000000')
                .fontWeight(FontWeight.Medium)
                .margin({ left: 12 })

              TextArea({ text: this.content })
                .backgroundColor(Color.White)
                .maxLength(50)
                .showCounter(true, { thresholdPercentage: 1, highlightBorder: true })
                .height(72)
                .padding({ top: 8, right: 16, bottom: 8, left: 16 })
                .margin({ top: 8 })
                .borderRadius(16)
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
                .height(32)
                .backgroundColor('#E8E8E8')
                .fontColor('#333333')
                .onClick(() => { this.showPresetPanel = !this.showPresetPanel; })
              Button('关键词过滤')
                .fontSize(13)
                .height(32)
                .backgroundColor('#E8E8E8')
                .fontColor('#333333')
                .onClick(() => { this.showKeywordPanel = !this.showKeywordPanel; })
              Button('历史记录')
                .fontSize(13)
                .height(32)
                .backgroundColor('#E8E8E8')
                .fontColor('#333333')
                .onClick(() => { this.pathInfos.pushPathByName('History', null); })
              Button('统计面板')
                .fontSize(13)
                .height(32)
                .backgroundColor('#E8E8E8')
                .fontColor('#333333')
                .onClick(() => { this.pathInfos.pushPathByName('Stats', null); })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
            .margin({ top: 8, bottom: 12 })

            if (this.showPresetPanel) {
              Column() {
                Text('预设模板库')
                  .fontSize(14)
                  .fontColor('#99000000')
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 12, top: 8 })

                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(PresetTemplates.getAll(), (template: PresetTemplate) => {
                    Button(template.label)
                      .fontSize(14)
                      .height(32)
                      .margin(4)
                      .backgroundColor('#F1F3F5')
                      .fontColor('#333333')
                      .onClick(() => { this.applyPreset(template); })
                  }, (template: PresetTemplate) => template.label)
                }
                .width('100%')
                .padding({ left: 12, right: 12, top: 8, bottom: 12 })
              }
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(16)
              .margin({ bottom: 12 })
            }

            if (this.showKeywordPanel) {
              Column() {
                Text('关键词过滤')
                  .fontSize(14)
                  .fontColor('#99000000')
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 12, top: 8, bottom: 8 })

                Row() {
                  TextInput({ text: this.filterKeyword, placeholder: '输入过滤关键词' })
                    .layoutWeight(1)
                    .height(36)
                    .borderRadius(8)
                    .onChange((value: string) => { this.filterKeyword = value; })
                  Button('添加')
                    .fontSize(13)
                    .height(36)
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
                          .fontColor('#333333')
                          .margin({ right: 4 })
                        Text('×')
                          .fontSize(13)
                          .fontColor('#999999')
                          .onClick(() => { this.removeKeyword(keyword); })
                      }
                      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                      .margin(4)
                      .backgroundColor('#F1F3F5')
                      .borderRadius(12)
                    }, (keyword: string) => keyword)
                  }
                  .width('100%')
                  .padding({ left: 12, right: 12, bottom: 12 })
                }
              }
              .width('100%')
              .backgroundColor(Color.White)
              .borderRadius(16)
              .margin({ bottom: 12 })
            }

            Column() {
              this.buildSectionHeader('显示设置');

              Column() {
                Column() {
                  Row() {
                    Text('字体大小')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                    Text(this.fontSizeFlag)
                      .fontSize(14)
                  }
                  .width('100%')
                  .height(48)
                  .justifyContent(FlexAlign.SpaceBetween)

                  Slider({
                    value: this.fontSize,
                    min: 88,
                    max: 248,
                    step: 80,
                    style: SliderStyle.InSet
                  })
                    .width('calc(100% + 12vp)')
                    .height(40)
                    .blockColor(Color.White)
                    .trackColor('#F1F3F5')
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
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                  Select([
                    { value: this.fontWeights[0].toString() },
                    { value: this.fontWeights[1].toString() },
                    { value: this.fontWeights[2].toString() }
                  ])
                    .value(this.fontWeight.toString())
                    .selected(this.selectedIndex)
                    .backgroundColor('#FFFFFF')
                    .fontColor('#99000000')
                    .borderWidth(0)
                    .onSelect((index: number) => {
                      this.fontWeight = this.fontWeights[index];
                      this.selectedIndex = index;
                    })
                }
                .width('100%')
                .height(48)
                .margin({ top: 12 })
                .justifyContent(FlexAlign.SpaceBetween)

                if (this.displayMode === DisplayMode.SLIDE) {
                  Row() {
                    Text('弹幕速度')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                    Text(this.speedFlag)
                      .fontSize(14)
                  }
                  .width('100%')
                  .height(48)
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
                    .height(40)
                    .blockColor(Color.White)
                    .trackColor('#F1F3F5')
                    .selectedColor('#0A59F7')
                    .onChange((value: number) => {
                      this.handleSpeedChange(value);
                    })
                }

                Row() {
                  Text('弹幕颜色')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                  Row() {
                    Circle()
                      .width(24)
                      .height(24)
                      .fill(this.fontColor)
                      .border({ width: 1, color: '#CCCCCC' })
                    TextInput({ text: this.fontColor })
                      .width(100)
                      .height(32)
                      .fontSize(12)
                      .margin({ left: 8 })
                      .borderRadius(8)
                      .onChange((value: string) => {
                        if (value.startsWith('#') && value.length === 7) {
                          this.fontColor = value;
                        }
                      })
                  }
                }
                .width('100%')
                .height(48)
                .margin({ top: 12 })
                .justifyContent(FlexAlign.SpaceBetween)

                Row() {
                  Text('显示方式')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                  Select([
                    { value: '滑动弹幕' },
                    { value: '滞留弹幕' }
                  ])
                    .value(this.displayModeIndex === 0 ? '滑动弹幕' : '滞留弹幕')
                    .selected(this.displayModeIndex)
                    .backgroundColor('#FFFFFF')
                    .fontColor('#99000000')
                    .borderWidth(0)
                    .onSelect((index: number) => {
                      this.displayModeIndex = index;
                      const modes = [DisplayMode.SLIDE, DisplayMode.STATIC];
                      this.displayMode = modes[index];
                    })
                }
                .width('100%')
                .height(48)
                .margin({ top: 12 })
                .justifyContent(FlexAlign.SpaceBetween)

                Row() {
                  Text('显示区域')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                  Select([
                    { value: '上方' },
                    { value: '居中' },
                    { value: '下方' }
                  ])
                    .value(this.displayAreaIndex === 0 ? '上方' : this.displayAreaIndex === 1 ? '居中' : '下方')
                    .selected(this.displayAreaIndex)
                    .backgroundColor('#FFFFFF')
                    .fontColor('#99000000')
                    .borderWidth(0)
                    .onSelect((index: number) => {
                      this.handleDisplayAreaChange(index);
                    })
                }
                .width('100%')
                .height(48)
                .margin({ top: 12 })
                .justifyContent(FlexAlign.SpaceBetween)

                Row() {
                  Text('弹幕主题')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                  Select(ThemeManager.getAllThemeNames().map((name: string): SelectOption => { return { value: name }; }))
                    .value(this.themeName)
                    .selected(this.themeIndex)
                    .backgroundColor('#FFFFFF')
                    .fontColor('#99000000')
                    .borderWidth(0)
                    .onSelect((index: number) => {
                      this.handleThemeChange(index);
                    })
                }
                .width('100%')
                .height(48)
                .margin({ top: 12 })
                .justifyContent(FlexAlign.SpaceBetween)
              }
              .width('100%')
              .padding({ left: 12, right: 12, top: 4, bottom: 4 })
              .margin({ bottom: 12 })
              .backgroundColor(Color.White)
              .borderRadius(16)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Button('显示弹幕')
              .height(40)
              .backgroundColor('#0A59F7')
              .margin({ top: 32, bottom: 32 })
              .width('100%')
              .onClick(() => { this.onSendDanmu(); })
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .background('#F1F3F5')
      .alignItems(HorizontalAlign.Start)
    }
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
  }
}
