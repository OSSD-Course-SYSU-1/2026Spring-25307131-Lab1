import { StatsManager, DailyStat } from '../utils/StatsManager';
import { Context } from '@kit.AbilityKit';

@ComponentV2
export struct StatsPage {
  @Local dailyStats: DailyStat[] = [];
  @Local totalCount: number = 0;
  @Local avgPerDay: number = 0;
  @Local isLoading: boolean = true;
  statsManager: StatsManager = new StatsManager();

  aboutToAppear(): void {
    const context = getContext(this) as Context;
    this.loadData(context);
  }

  private async loadData(context: Context): Promise<void> {
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
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Scroll() {
            Column() {
              Row() {
                Column() {
                  Text('总发送量')
                    .fontSize(13)
                    .fontColor('#999999')
                  Text(`${this.totalCount}`)
                    .fontSize(28)
                    .fontColor('#0A59F7')
                    .fontWeight(FontWeight.Bold)
                    .margin({ top: 4 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)

                Column() {
                  Text('日均发送')
                    .fontSize(13)
                    .fontColor('#999999')
                  Text(`${this.avgPerDay}`)
                    .fontSize(28)
                    .fontColor('#43A1F4')
                    .fontWeight(FontWeight.Bold)
                    .margin({ top: 4 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)

                Column() {
                  Text('记录天数')
                    .fontSize(13)
                    .fontColor('#999999')
                  Text(`${this.dailyStats.length}`)
                    .fontSize(28)
                    .fontColor('#2E7D32')
                    .fontWeight(FontWeight.Bold)
                    .margin({ top: 4 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(16)
              .margin({ top: 16, left: 16, right: 16 })

              Column() {
                Text('每日发送统计')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ left: 16, top: 16, bottom: 8 })

                if (this.dailyStats.length === 0) {
                  Column() {
                    Text('暂无统计数据')
                      .fontSize(14)
                      .fontColor('#999999')
                  }
                  .width('100%')
                  .height(200)
                  .justifyContent(FlexAlign.Center)
                } else {
                  Scroll() {
                    Row() {
                      ForEach(this.dailyStats, (stat: DailyStat) => {
                        Column() {
                          Column() {
                          }
                          .width(24)
                          .height(Math.max(4, (stat.count / this.getMaxCount()) * 160))
                          .backgroundColor('#0A59F7')
                          .borderRadius({ topLeft: 4, topRight: 4 })

                          Text(`${stat.count}`)
                            .fontSize(10)
                            .fontColor('#333333')
                            .margin({ top: 4 })

                          Text(stat.date.slice(5))
                            .fontSize(9)
                            .fontColor('#999999')
                            .margin({ top: 2 })
                        }
                        .margin({ left: 4, right: 4 })
                        .alignItems(HorizontalAlign.Center)
                        .justifyContent(FlexAlign.End)
                      }, (stat: DailyStat) => stat.date)
                    }
                    .height(220)
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
              .borderRadius(16)
              .margin({ top: 16, left: 16, right: 16, bottom: 32 })
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')
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
