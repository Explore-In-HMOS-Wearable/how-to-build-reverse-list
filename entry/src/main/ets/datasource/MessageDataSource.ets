import { Msg } from '../model/Message';

export class MsgDataSource implements IDataSource {
  private items: Msg[] = [];
  private listeners: DataChangeListener[] = [];

  constructor(initial: Msg[] = []) {
    this.items = initial;
  }

  totalCount(): number {
    return this.items.length;
  }

  getData(index: number): Msg {
    return this.items[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos: number = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  append(item: Msg): void {
    this.items.push(item);
    const at: number = this.items.length - 1;
    this.listeners.forEach((l: DataChangeListener) => l.onDataAdd(at));
  }

  prependPage(page: Msg[]): void {
    for (let i: number = page.length - 1; i >= 0; i--) {
      this.items.splice(0, 0, page[i]);
      this.listeners.forEach((l: DataChangeListener) => l.onDataAdd(0));
    }
  }

  remove(index: number): void {
    this.items.splice(index, 1);
    this.listeners.forEach((l: DataChangeListener) => l.onDataDelete(index));
  }

  indexOfId(id: string): number {
    return this.items.findIndex((m: Msg) => m.id === id);
  }

  oldestTimestamp(): number {
    return this.items.length > 0 ? this.items[0].timestamp : Date.now();
  }
}