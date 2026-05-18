import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'StatsManager';
const STORE_NAME = 'danmu_stats';
const KEY_DAILY = 'daily_stats';

export interface DailyStat {
  date: string;
  count: number;
}

export class StatsManager {
  private prefs?: preferences.Preferences;

  async init(context: Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, STORE_NAME);
    } catch (error) {
      hilog.error(0x0000, TAG, `init failed: ${error}`);
    }
  }

  private getTodayStr(): string {
    const now = new Date();
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
  }

  async recordSend(): Promise<void> {
    if (!this.prefs) {
      return;
    }
    const today = this.getTodayStr();
    let list: DailyStat[] = await this.getDailyStats();
    const found = list.find(item => item.date === today);
    if (found) {
      found.count += 1;
    } else {
      list.push({ date: today, count: 1 });
    }
    if (list.length > 30) {
      list = list.slice(list.length - 30);
    }
    await this.prefs.put(KEY_DAILY, JSON.stringify(list));
    await this.prefs.flush();
  }

  async getDailyStats(): Promise<DailyStat[]> {
    if (!this.prefs) {
      return [];
    }
    try {
      const raw = await this.prefs.get(KEY_DAILY, '[]') as string;
      return JSON.parse(raw) as DailyStat[];
    } catch (error) {
      return [];
    }
  }

  async getTotalCount(): Promise<number> {
    const list = await this.getDailyStats();
    return list.reduce((sum, item) => sum + item.count, 0);
  }

  async getAvgPerDay(): Promise<number> {
    const list = await this.getDailyStats();
    if (list.length === 0) {
      return 0;
    }
    const total = list.reduce((sum, item) => sum + item.count, 0);
    return Math.round(total / list.length);
  }
}
