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

export enum DisplayArea {
  TOP = 'top',
  CENTER = 'center',
  BOTTOM = 'bottom'
}

export enum DisplayMode {
  SLIDE = 'slide',
  STATIC = 'static'
}

export interface SettingsRecord {
  content: string;
  fontSize: number;
  fontWeight: number;
  fontColor: string;
  speed: number;
  displayArea: DisplayArea;
  displayMode: DisplayMode;
  bgColor: string[];
  themeName: string;
}

export class Settings {
  content: string = '';
  fontSize: number = 0;
  fontWeight: FontWeight = FontWeight.Regular;
  fontColor: string = '#FFFFFF';
  speed: number = 6;
  displayArea: DisplayArea = DisplayArea.CENTER;
  displayMode: DisplayMode = DisplayMode.SLIDE;
  bgColor: string[] = ['#013C9C', '#3066E4', '#43A1F4'];
  themeName: string = '默认蓝';

  constructor(
    content: string,
    fontSize: number,
    fontWeight: FontWeight,
    fontColor?: string,
    speed?: number,
    displayArea?: DisplayArea,
    displayMode?: DisplayMode,
    bgColor?: string[],
    themeName?: string
  ) {
    this.content = content;
    this.fontSize = fontSize;
    this.fontWeight = fontWeight;
    if (fontColor !== undefined) {
      this.fontColor = fontColor;
    }
    if (speed !== undefined) {
      this.speed = speed;
    }
    if (displayArea !== undefined) {
      this.displayArea = displayArea;
    }
    if (displayMode !== undefined) {
      this.displayMode = displayMode;
    }
    if (bgColor !== undefined) {
      this.bgColor = bgColor;
    }
    if (themeName !== undefined) {
      this.themeName = themeName;
    }
  }

  toRecord(): SettingsRecord {
    const record: SettingsRecord = {
      content: this.content,
      fontSize: this.fontSize,
      fontWeight: this.fontWeight as number,
      fontColor: this.fontColor,
      speed: this.speed,
      displayArea: this.displayArea,
      displayMode: this.displayMode,
      bgColor: this.bgColor,
      themeName: this.themeName
    };
    return record;
  }

  static fromRecord(record: SettingsRecord): Settings {
    let fw: FontWeight = FontWeight.Regular;
    if (record.fontWeight === FontWeight.Medium as number) {
      fw = FontWeight.Medium;
    } else if (record.fontWeight === FontWeight.Bold as number) {
      fw = FontWeight.Bold;
    }
    return new Settings(
      record.content,
      record.fontSize,
      fw,
      record.fontColor,
      record.speed,
      record.displayArea,
      record.displayMode,
      record.bgColor,
      record.themeName
    );
  }
}
