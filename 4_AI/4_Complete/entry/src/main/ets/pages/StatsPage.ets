import { StatsManager, DailyStat } from '../utils/StatsManager';
import { common } from '@kit.AbilityKit';

@ComponentV2
export struct StatsPage {
  @Local dailyStats: DailyStat[] = [];
  @Local totalCount: number = 0;
  @Local avgPerDay: number = 0;
  @Local isLoading: boolean = true;
  @Local currentBreakpoint: string = 'sm';
  statsManager: StatsManager = new StatsManager();

  private labelFontSize(): number {
    if (this.currentBreakpoint === 'lg') return 16;
    if (this.currentBreakpoint === 'md') return 14;
    return 13;
  }

  private statNumberFontSize(): number {
    if (this.currentBreakpoint === 'lg') return 36;
    if (this.currentBreakpoint === 'md') return 32;
    return 28;
  }

  private chartBarWidth(): number {
    if (this.currentBreakpoint === 'lg') return 32;
    if (this.currentBreakpoint === 'md') return 28;
    return 24;
  }

  private chartMaxHeight(): number {
    if (this.currentBreakpoint === 'lg') return 240;
    if (this.currentBreakpoint === 'md') return 200;
    return 160;
  }

  private chartContainerHeight(): number {
    if (this.currentBreakpoint === 'lg') return 300;
    if (this.currentBreakpoint === 'md') return 260;
    return 220;
  }

  private chartCountFontSize(): number {
    if (this.currentBreakpoint === 'lg') return 13;
    if (this.currentBreakpoint === 'md') return 11;
    return 10;
  }

  private chartDateFontSize(): number {
    if (this.currentBreakpoint === 'lg') return 11;
    if (this.currentBreakpoint === 'md') return 10;
    return 9;
  }

  aboutToAppear(): void {
    const context = this.getUIContext().getHostContext() as common.Context;
    this.loadData(context);
  }

  private async loadData(context: common.Context): Promise<void> {
    await this.statsManager.init(context);
    this.dailyStats = await this.statsManager.getDailyStats();
    this.totalCount = await this.statsManager.getTotalCount();
    this.avgPerDay = await this.statsManager.getAvgPerDay();
    this.isLoading = false;
  }

  private getMaxCount(): number {
    if (this.dailyStats.length === 0) {
      return 1;
    }
    let max = 0;
    for (const stat of this.dailyStats) {
      if (stat.count > max) {
        max = stat.count;
      }
    }
    return max > 0 ? max : 1;
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(48)
              .height(48)
              .color('#0A59F7')
            Text('加载中...')
              .fontSize(this.labelFontSize())
              .fontColor('#5F6368')
              .margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              GridRow({
                columns: { sm: 1, md: 2, lg: 3 },
                gutter: { x: 16 },
                breakpoints: { value: ['600vp', '840vp'] }
              }) {
                GridCol({ span: { sm: 1, md: 1, lg: 1 } }) {
                  Row() {
                    Column() {
                      Text('总发送量')
                        .fontSize(this.labelFontSize())
                        .fontColor('#5F6368')
                      Text(`${this.totalCount}`)
                        .fontSize(this.statNumberFontSize())
                        .fontColor('#58A6FF')
                        .fontWeight(FontWeight.Bold)
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)

                    Column() {
                      Text('日均发送')
                        .fontSize(this.labelFontSize())
                        .fontColor('#5F6368')
                      Text(`${this.avgPerDay}`)
                        .fontSize(this.statNumberFontSize())
                        .fontColor('#00D4FF')
                        .fontWeight(FontWeight.Bold)
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)

                    Column() {
                      Text('记录天数')
                        .fontSize(this.labelFontSize())
                        .fontColor('#5F6368')
                      Text(`${this.dailyStats.length}`)
                        .fontSize(this.statNumberFontSize())
                        .fontColor('#3FB950')
                        .fontWeight(FontWeight.Bold)
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Center)
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor(Color.White)
                  .border({ width: 1, color: 'rgba(0,0,0,0.06)' })
                  .borderRadius(16)
                }

                GridCol({ span: { sm: 1, md: 1, lg: 1 } }) {
                  Column() {
                    Text('每日发送统计')
                      .fontSize(this.labelFontSize() + 2)
                      .fontWeight(FontWeight.Medium)
                      .margin({ left: 16, top: 16, bottom: 8 })

                    if (this.dailyStats.length === 0) {
                      Column() {
                        Text('暂无统计数据')
                          .fontSize(this.labelFontSize())
                          .fontColor('#999999')
                      }
                      .width('100%')
                      .height(this.chartContainerHeight())
                      .justifyContent(FlexAlign.Center)
                    } else {
                      Scroll() {
                        Row() {
                          ForEach(this.dailyStats, (stat: DailyStat) => {
                            Column() {
                              Column() {
                              }
                              .width(this.chartBarWidth())
                              .height(Math.max(4, (stat.count / this.getMaxCount()) * this.chartMaxHeight()))
                              .linearGradient({
                                direction: GradientDirection.Bottom,
                                colors: [['#0A59F7', 0.0], ['#40C4FF', 1.0]]
                              })
                              .borderRadius({ topLeft: 4, topRight: 4 })

                              Text(`${stat.count}`)
                                .fontSize(this.chartCountFontSize())
                                .fontColor('#5F6368')
                                .margin({ top: 4 })

                              Text(stat.date.slice(5))
                                .fontSize(this.chartDateFontSize())
                                .fontColor('#5F6368')
                                .margin({ top: 2 })
                            }
                            .margin({ left: 4, right: 4 })
                            .alignItems(HorizontalAlign.Center)
                            .justifyContent(FlexAlign.End)
                          }, (stat: DailyStat) => stat.date)
                        }
                        .height(this.chartContainerHeight())
                        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
                        .alignItems(VerticalAlign.Bottom)
                      }
                      .scrollable(ScrollDirection.Horizontal)
                      .scrollBar(BarState.Off)
                      .width('100%')
                    }
                  }
                  .width('100%')
                  .backgroundColor(Color.White)
                  .border({ width: 1, color: 'rgba(0,0,0,0.06)' })
                  .borderRadius(16)
                }
              }
              .margin({ top: 16, left: 16, right: 16, bottom: 32 })
              .onBreakpointChange((breakpoint: string) => {
                this.currentBreakpoint = breakpoint;
              })
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#E8EDF2')
    }
    .title('弹幕统计面板')
    .hideTitleBar(false)
    .backButtonIcon($r('app.media.chevron_left'))
  }
}

@Builder
export function StatsBuilder() {
  StatsPage();
}
