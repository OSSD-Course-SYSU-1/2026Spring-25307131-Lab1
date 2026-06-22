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

import { window } from '@kit.ArkUI';
import { Settings, DisplayArea, DisplayMode } from '../model/Settings';
import { Speaker } from '../utils/Speaker';

@ComponentV2
export struct Led {
  @Local settings: Settings = new Settings('', 88, FontWeight.Regular);
  @Local screenWidth: number = 0;
  speaker: Speaker = new Speaker();

  aboutToDisappear(): void {
    this.speaker.stopSpeak();
    this.speaker.shutdownEngine();
  }

  private getContentAlign(): FlexAlign {
    if (this.settings.displayArea === DisplayArea.TOP) {
      return FlexAlign.Start;
    } else if (this.settings.displayArea === DisplayArea.BOTTOM) {
      return FlexAlign.End;
    }
    return FlexAlign.Center;
  }

  private getAdaptiveFontSize(): number {
    if (this.screenWidth <= 0) {
      return this.settings.fontSize;
    }
    const scale = Math.min(this.screenWidth / 800, 2.0);
    return Math.round(this.settings.fontSize * scale);
  }

  private getPreferredOrientation(): window.Orientation {
    if (this.screenWidth > 0 && this.screenWidth >= 840) {
      return window.Orientation.UNSPECIFIED;
    }
    return window.Orientation.LANDSCAPE;
  }

  private getShadowRadius(): number {
    if (this.screenWidth >= 1200) return 16;
    if (this.screenWidth >= 840) return 12;
    return 8;
  }

  build() {
    NavDestination() {
      Column() {
        if (this.settings.displayMode === DisplayMode.SLIDE) {
          Text(this.settings.content)
            .textOverflow({ overflow: TextOverflow.MARQUEE })
            .marqueeOptions({
              start: true,
              step: this.settings.speed
            })
            .fontSize(this.getAdaptiveFontSize())
            .fontWeight(this.settings.fontWeight)
            .fontColor(this.settings.fontColor)
            .shadow({
              radius: this.getShadowRadius(),
              color: 'rgba(0, 0, 0, 0.5)',
              offsetX: 2,
              offsetY: 2
            })
        } else {
          Text(this.settings.content)
            .fontSize(this.getAdaptiveFontSize())
            .fontWeight(this.settings.fontWeight)
            .fontColor(this.settings.fontColor)
            .textAlign(TextAlign.Center)
            .shadow({
              radius: this.getShadowRadius(),
              color: 'rgba(0, 0, 0, 0.5)',
              offsetX: 2,
              offsetY: 2
            })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(this.getContentAlign())
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.screenWidth = newValue.width as number;
      })
    }
    .onReady((context: NavDestinationContext) => {
      this.settings = context.pathInfo.param as Settings;
    })
    .width('100%')
    .height('100%')
    .menus([{
      value: '',
      icon: $r('app.media.speaker_wave_3'),
      action: () => {
        this.speaker.startSpeak(this.settings.content);
      }
    }])
    .backButtonIcon($r('app.media.chevron_left'))
    .preferredOrientation(this.getPreferredOrientation())
    .linearGradient({
      direction: GradientDirection.Right,
      colors: [
        [this.settings.bgColor[0], 0.0],
        [this.settings.bgColor[1], 0.5],
        [this.settings.bgColor[2], 1.0]
      ]
    })
  }
}

@Builder
export function LedBuilder() {
  Led();
}
