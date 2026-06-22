import { HistoryManager, HistoryItem } from '../utils/HistoryManager';
import { common } from '@kit.AbilityKit';

@ComponentV2
export struct HistoryPage {
  @Local historyList: HistoryItem[] = [];
  @Local isLoading: boolean = true;
  @Local currentBreakpoint: string = 'sm';
  historyManager: HistoryManager = new HistoryManager();

  private contentFontSize(): number {
    if (this.currentBreakpoint === 'lg') return 18;
    if (this.currentBreakpoint === 'md') return 16;
    return 15;
  }

  private metaFontSize(): number {
    if (this.currentBreakpoint === 'lg') return 14;
    if (this.currentBreakpoint === 'md') return 13;
    return 12;
  }

  private btnHeight(): number {
    return this.currentBreakpoint === 'sm' ? 44 : 48;
  }

  aboutToAppear(): void {
    const context = this.getUIContext().getHostContext() as common.Context;
    this.loadData(context);
  }

  private async loadData(context: common.Context): Promise<void> {
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
              .fontSize(this.metaFontSize())
              .fontColor('#5F6368')
              .margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.historyList.length === 0) {
          Column() {
            Text('暂无弹幕记录')
              .fontSize(this.contentFontSize())
              .fontColor('#5F6368')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Column() {
            Row() {
              Text(`共 ${this.historyList.length} 条记录`)
                .fontSize(this.metaFontSize())
                .fontColor('#5F6368')
              Button('清空')
                .fontSize(13)
                .height(this.btnHeight())
                .backgroundColor('#F85149')
                .fontColor('#FFFFFF')
                .borderRadius(14)
                .shadow({ radius: 8, color: 'rgba(248,81,73,0.3)', offsetX: 0, offsetY: 2 })
                .onClick(() => { this.clearAll(); })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })

            GridRow({
              columns: { sm: 1, md: 2, lg: 3 },
              gutter: { x: 8, y: 8 },
              breakpoints: { value: ['600vp', '840vp'] }
            }) {
              ForEach(this.historyList, (item: HistoryItem, index?: number) => {
                GridCol({ span: { sm: 1, md: 1, lg: 1 } }) {
                  Row() {
                    Column() {
                      Text(item.content)
                        .fontSize(this.contentFontSize())
                        .fontColor('#1A1C1E')
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Text(this.formatTime(item.timestamp))
                        .fontSize(this.metaFontSize())
                        .fontColor('#5F6368')
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
                  .border({ width: 1, color: 'rgba(0,0,0,0.06)' })
                  .borderRadius(12)
                }
                .padding({ left: 8, right: 8 })
              }, (item: HistoryItem, index?: number) => `${item.timestamp}_${index}`)
            }
            .width('100%')
            .layoutWeight(1)
            .margin({ top: 4 })
            .onBreakpointChange((breakpoint: string) => {
              this.currentBreakpoint = breakpoint;
            })
          }
          .width('100%')
          .height('100%')
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#E8EDF2')
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
