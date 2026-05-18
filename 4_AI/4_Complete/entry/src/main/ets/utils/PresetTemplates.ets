export interface PresetTemplate {
  label: string;
  content: string;
}

export class PresetTemplates {
  static readonly templates: PresetTemplate[] = [
    { label: '666', content: '666' },
    { label: '前方高能', content: '前方高能' },
    { label: '哈哈哈哈', content: '哈哈哈哈' },
    { label: '太棒了', content: '太棒了' },
    { label: '加油', content: '加油' },
    { label: '冲冲冲', content: '冲冲冲' },
    { label: '厉害了', content: '厉害了' },
    { label: '哈哈哈', content: '哈哈哈' },
    { label: '可以的', content: '可以的' },
    { label: '大佬', content: '大佬' },
    { label: '好厉害', content: '好厉害' },
    { label: '赞', content: '赞' },
  ];

  static getAll(): PresetTemplate[] {
    return PresetTemplates.templates;
  }

  static getContentByLabel(label: string): string {
    const found = PresetTemplates.templates.find(t => t.label === label);
    return found ? found.content : '';
  }
}
