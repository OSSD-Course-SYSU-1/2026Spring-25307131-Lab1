import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'HistoryManager';
const STORE_NAME = 'danmu_history';
const KEY_HISTORY = 'history_list';

export interface HistoryItem {
  content: string;
  timestamp: number;
  fontColor: string;
}

export class HistoryManager {
  private prefs?: preferences.Preferences;

  async init(context: common.Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, STORE_NAME);
    } catch (error) {
      hilog.error(0x0000, TAG, `init failed: ${error}`);
    }
  }

  async addHistory(item: HistoryItem): Promise<void> {
    if (!this.prefs) {
      return;
    }
    try {
      let list: HistoryItem[] = await this.getHistory();
      list.unshift(item);
      if (list.length > 100) {
        list = list.slice(0, 100);
      }
      await this.prefs.put(KEY_HISTORY, JSON.stringify(list));
      await this.prefs.flush();
    } catch (error) {
      hilog.error(0x0000, TAG, `addHistory failed: ${error}`);
    }
  }

  async getHistory(): Promise<HistoryItem[]> {
    if (!this.prefs) {
      return [];
    }
    try {
      const raw = await this.prefs.get(KEY_HISTORY, '[]') as string;
      return JSON.parse(raw) as HistoryItem[];
    } catch (error) {
      return [];
    }
  }

  async clearHistory(): Promise<void> {
    if (!this.prefs) {
      return;
    }
    try {
      await this.prefs.put(KEY_HISTORY, '[]');
      await this.prefs.flush();
    } catch (error) {
      hilog.error(0x0000, TAG, `clearHistory failed: ${error}`);
    }
  }
}
