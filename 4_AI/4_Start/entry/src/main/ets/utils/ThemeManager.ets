export interface ThemeConfig {
  name: string;
  bgColors: string[];
  defaultFontColor: string;
}

export class ThemeManager {
  static readonly themes: ThemeConfig[] = [
    {
      name: '默认蓝',
      bgColors: ['#013C9C', '#3066E4', '#43A1F4'],
      defaultFontColor: '#FFFFFF'
    },
    {
      name: '暗夜黑',
      bgColors: ['#1A1A2E', '#16213E', '#0F3460'],
      defaultFontColor: '#E0E0E0'
    },
    {
      name: '烈焰红',
      bgColors: ['#8B0000', '#C62828', '#E53935'],
      defaultFontColor: '#FFFFFF'
    },
    {
      name: '翡翠绿',
      bgColors: ['#1B5E20', '#2E7D32', '#43A047'],
      defaultFontColor: '#FFFFFF'
    },
    {
      name: '暮光紫',
      bgColors: ['#4A148C', '#6A1B9A', '#8E24AA'],
      defaultFontColor: '#FFFFFF'
    },
    {
      name: '极简白',
      bgColors: ['#F5F5F5', '#E0E0E0', '#BDBDBD'],
      defaultFontColor: '#212121'
    },
    {
      name: '赛博霓虹',
      bgColors: ['#0D0221', '#150734', '#1A0A3E'],
      defaultFontColor: '#00FFFF'
    },
    {
      name: '日落橙',
      bgColors: ['#E65100', '#F57C00', '#FF9800'],
      defaultFontColor: '#FFFFFF'
    }
  ];

  static getThemeByName(name: string): ThemeConfig {
    const found = ThemeManager.themes.find(t => t.name === name);
    return found ? found : ThemeManager.themes[0];
  }

  static getAllThemeNames(): string[] {
    return ThemeManager.themes.map(t => t.name);
  }
}
