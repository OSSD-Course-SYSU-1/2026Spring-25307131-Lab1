import { HistoryManager, HistoryItem } from '../utils/HistoryManager';
import { Context } from '@kit.AbilityKit';

@ComponentV2
export struct HistoryPage {
  @Local historyList: HistoryItem[] = [];
  @Local isLoading: boolean = true;
  historyManager: HistoryManager = new HistoryManager();

  aboutToAppear(): void {
    const context = getContext(this) as Context;
    this.loadData(context);
  }

  private async loadData(context: Context): Promise<void> {
    await this.historyManager.init(context);
    this.historyList = await this.historyManager.getHistory();
    this.isLoading = false;
  }

  private formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hour = String(date.getHours()).padStart(2, '0');
    const minute = String(date.getMinutes()).padStart(2, '0');
    return `${month}-${day} ${hour}:${minute}`;
  }

  private async clearAll(): Promise<void> {
    await this.historyManager.clearHistory();
    this.historyList = [];
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
        } else if (this.historyList.length === 0) {
          Column() {
            Text('暂无弹幕记录')
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Column() {
            Row() {
              Text(`共 ${this.historyList.length} 条记录`)
                .fontSize(13)
                .fontColor('#999999')
              Button('清空')
                .fontSize(13)
                .height(28)
                .backgroundColor('#FF4444')
                .fontColor('#FFFFFF')
                .borderRadius(14)
                .onClick(() => { this.clearAll(); })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })

            List() {
              ForEach(this.historyList, (item: HistoryItem, index?: number) => {
                ListItem() {
                  Row() {
                    Column() {
                      Text(item.content)
                        .fontSize(15)
                        .fontColor('#333333')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Text(this.formatTime(item.timestamp))
                        .fontSize(12)
                        .fontColor('#999999')
                        .margin({ top: 4 })
                    }
                    .alignItems(HorizontalAlign.Start)
                    .layoutWeight(1)

                    Circle()
                      .width(12)
                      .height(12)
                      .fill(item.fontColor)
                      .border({ width: 1, color: '#CCCCCC' })
                  }
                  .width('100%')
                  .padding(16)
                  .backgroundColor(Color.White)
                  .borderRadius(12)
                }
                .margin({ top: 8, left: 16, right: 16 })
              }, (item: HistoryItem, index?: number) => `${item.timestamp}_${index}`)
            }
            .width('100%')
            .layoutWeight(1)
            .margin({ top: 4 })
          }
          .width('100%')
          .height('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F1F3F5')
    }
    .title('弹幕历史记录')
    .hideTitleBar(false)
    .backButtonIcon($r('app.media.chevron_left'))
  }
}

@Builder
export function HistoryBuilder() {
  HistoryPage();
}
