import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'KeywordFilter';
const STORE_NAME = 'danmu_keyword';
const KEY_KEYWORDS = 'filter_keywords';

export class KeywordFilter {
  private prefs?: preferences.Preferences;
  private keywords: string[] = [];

  async init(context: common.Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, STORE_NAME);
      this.keywords = await this.getKeywords();
    } catch (error) {
      hilog.error(0x0000, TAG, `init failed: ${error}`);
    }
  }

  async getKeywords(): Promise<string[]> {
    if (!this.prefs) {
      return [];
    }
    try {
      const raw = await this.prefs.get(KEY_KEYWORDS, '[]') as string;
      this.keywords = JSON.parse(raw) as string[];
      return this.keywords;
    } catch (error) {
      return [];
    }
  }

  async addKeyword(keyword: string): Promise<void> {
    if (!this.prefs || this.keywords.includes(keyword)) {
      return;
    }
    try {
      this.keywords.push(keyword);
      await this.prefs.put(KEY_KEYWORDS, JSON.stringify(this.keywords));
      await this.prefs.flush();
    } catch (error) {
      hilog.error(0x0000, TAG, `addKeyword failed: ${error}`);
    }
  }

  async removeKeyword(keyword: string): Promise<void> {
    if (!this.prefs) {
      return;
    }
    try {
      this.keywords = this.keywords.filter(k => k !== keyword);
      await this.prefs.put(KEY_KEYWORDS, JSON.stringify(this.keywords));
      await this.prefs.flush();
    } catch (error) {
      hilog.error(0x0000, TAG, `removeKeyword failed: ${error}`);
    }
  }

  filterContent(content: string): string {
    let result = content;
    for (const keyword of this.keywords) {
      if (keyword.length > 0) {
        const replacement = '*'.repeat(keyword.length);
        result = result.split(keyword).join(replacement);
      }
    }
    return result;
  }

  containsKeyword(content: string): boolean {
    for (const keyword of this.keywords) {
      if (keyword.length > 0 && content.includes(keyword)) {
        return true;
      }
    }
    return false;
  }
}
