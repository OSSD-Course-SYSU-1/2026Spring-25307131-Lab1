import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'KeywordFilter';
const STORE_NAME = 'danmu_keyword';
const KEY_KEYWORDS = 'filter_keywords';

export class KeywordFilter {
  private prefs?: preferences.Preferences;
  private keywords: string[] = [];

  async init(context: Context): Promise<void> {
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
    this.keywords.push(keyword);
    await this.prefs.put(KEY_KEYWORDS, JSON.stringify(this.keywords));
    await this.prefs.flush();
  }

  async removeKeyword(keyword: string): Promise<void> {
    if (!this.prefs) {
      return;
    }
    this.keywords = this.keywords.filter(k => k !== keyword);
    await this.prefs.put(KEY_KEYWORDS, JSON.stringify(this.keywords));
    await this.prefs.flush();
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
