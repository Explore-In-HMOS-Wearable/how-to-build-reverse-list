import { MessageBubble } from '../component/MessageBubble';
import { Constants } from '../constants/Constants';
import { MsgDataSource } from '../datasource/MessageDataSource';
import { Msg, MsgStatus } from '../model/Message';

@Entry
@Component
struct ChatPage {
  private scroller: Scroller = new Scroller();
  private data: MsgDataSource = new MsgDataSource(seedMessages());
  private loadingOlder: boolean = false;
  private historyPagesLeft: number = 3;

  @State composerOpen: boolean = false;
  @State draft: string = '';
  @State atBottom: boolean = true;

  @Builder
  composerSheet() {
    Column() {
      Text('To John')
        .fontSize(12)
        .fontColor(Constants.C_FONT_DIM)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .width('100%')

      TextArea({ text: this.draft, placeholder: 'Message' })
        .width('100%')
        .constraintSize({ minHeight: 56, maxHeight: 96 })
        .fontSize(15)
        .fontColor(Constants.C_FONT)
        .placeholderColor(Constants.C_FONT_DIM)
        .backgroundColor(Constants.C_SURFACE)
        .borderRadius(14)
        .borderWidth(1)
        .borderColor(Constants.C_DIVIDER)
        .padding(10)
        .defaultFocus(true)
        .onChange((value: string) => {
          this.draft = value;
        })

      Row({ space: 6 }) {
        ForEach(Constants.QUICK_REPLIES.slice(0, 2), (reply: string) => {
          Button(reply)
            .fontSize(12)
            .height(28)
            .padding({ left: 12, right: 12 })
            .backgroundColor(Constants.C_SURFACE_ALT)
            .fontColor(Constants.C_FONT)
            .onClick(() => {
              this.draft = reply;
              this.commit();
            })
        }, (reply: string) => reply)
      }
      .margin({ top: 10 })
      .justifyContent(FlexAlign.Center)
      .width('100%')

      Row({ space: 10 }) {
        Button('Cancel')
          .fontSize(14)
          .height(38)
          .layoutWeight(1)
          .backgroundColor(Constants.C_SURFACE_ALT)
          .fontColor(Constants.C_FONT)
          .onClick(() => {
            this.composerOpen = false;
          })

        Button('Send')
          .fontSize(14)
          .height(38)
          .layoutWeight(1)
          .backgroundColor(Constants.C_BRAND)
          .fontColor(Constants.C_FONT_ON_BRAND)
          .enabled(this.draft.trim().length > 0)
          .onClick(() => this.commit())
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding({ left: Constants.MODAL_INSET, right: Constants.MODAL_INSET, top: 12, bottom: 12 })
    .backgroundColor(Constants.C_PAGE_BG)
  }

  build() {
    Column() {
      Text('John')
        .fontSize(14)
        .fontColor(Constants.C_FONT_DIM)
        .height(28)
        .margin({ top: 4 })

      Stack({ alignContent: Alignment.BottomEnd }) {
        List({
          scroller: this.scroller,
          space: 2,
          initialIndex: this.data.totalCount() - 1
        }) {
          LazyForEach(this.data, (msg: Msg) => {
            ListItem() {
              MessageBubble({ msg: msg })
                .reuseId(msg.id)
            }
          }, (msg: Msg) => msg.id)
        }
        .width('100%')
        .height('100%')
        .maintainVisibleContentPosition(true)
        .cachedCount(6)
        .edgeEffect(EdgeEffect.None)
        .scrollBar(BarState.Off)
        .focusable(true)
        .defaultFocus(true)
        .onScrollIndex((start: number, end: number) => {
          this.atBottom = end >= this.data.totalCount() - 1;
          if (start <= 2) {
            this.loadOlder();
          }
        })

        if (!this.atBottom) {
          Button() {
            SymbolGlyph($r('sys.symbol.arrow_down'))
          }
            .width(30)
            .height(30)
            .fontSize(14)
            .backgroundColor(Constants.C_SURFACE)
            .fontColor(Constants.C_FONT)
            .shadow({ radius: 6, color: Constants.C_DIVIDER, offsetY: 1 })
            .margin({ bottom: 4 })
            .onClick(() => {
              this.scroller.scrollEdge(Edge.Bottom);
              this.atBottom = true;
            })
        }
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: Constants.SAFE_INSET, right: Constants.SAFE_INSET })

      Button('Write')
        .fontSize(14)
        .height(38)
        .width('50%')
        .backgroundColor(Constants.C_BRAND)
        .fontColor(Constants.C_FONT_ON_BRAND)
        .margin({ top: 5, bottom: 10 })
        .onClick(() => {
          this.composerOpen = true;
        })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16})
    .backgroundColor(Constants.C_PAGE_BG)
    .justifyContent(FlexAlign.End)
    .bindContentCover($$this.composerOpen, this.composerSheet(), {
      modalTransition: ModalTransition.DEFAULT,
      backgroundColor: Constants.C_PAGE_BG
    })
  }

  commit(): void {
    const text: string = this.draft.trim();
    if (text.length === 0) {
      return;
    }
    const msg: Msg = new Msg(`local_${Date.now()}`, text, true, Date.now(), MsgStatus.SENDING);
    this.data.append(msg);
    this.draft = '';
    this.composerOpen = false;
    this.scroller.scrollEdge(Edge.Bottom);

    setTimeout(() => {
      msg.status = MsgStatus.SENT;
    }, 400);
    setTimeout(() => {
      msg.status = MsgStatus.DELIVERED;
    }, 1200);
  }

  receive(msg: Msg): void {
    const wasAtBottom: boolean = this.atBottom;
    this.data.append(msg);
    if (wasAtBottom) {
      this.scroller.scrollEdge(Edge.Bottom);
    }
  }

  loadOlder(): void {
    if (this.loadingOlder || this.historyPagesLeft <= 0) {
      return;
    }
    this.loadingOlder = true;

    setTimeout(() => {
      const base: number = this.data.oldestTimestamp();
      const page: Msg[] = [];
      for (let i: number = 0; i < 15; i++) {
        const t: number = base - (15 - i) * 60_000;
        page.push(new Msg(`hist_${t}`, `Older message ${this.historyPagesLeft}-${i}`,
          i % 3 === 0, t, MsgStatus.READ));
      }
      this.data.prependPage(page);
      this.historyPagesLeft--;
      this.loadingOlder = false;
    }, 500);
  }
}

function seedMessages(): Msg[] {
  const now: number = Date.now();
  const lines: string[] = [
    'Are you around this afternoon?',
    'After three works',
    'I will send the notes before then',
    'Perfect',
    'Did the watch build go through?',
    'It did, ping to launch works',
    'Scroll up for history.'
  ];
  const out: Msg[] = [];
  for (let i: number = 0; i < lines.length; i++) {
    out.push(new Msg(`seed_${i}`, lines[i], i % 2 === 1,
      now - (lines.length - i) * 120_000, MsgStatus.READ));
  }
  return out;
}