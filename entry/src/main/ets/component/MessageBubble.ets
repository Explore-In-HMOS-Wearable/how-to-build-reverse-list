import { Constants } from '../constants/Constants';
import { Msg, MsgStatus } from '../model/Message';

function formatTime(ts: number): string {
  const d: Date = new Date(ts);
  const h: string = d.getHours().toString().padStart(2, '0');
  const m: string = d.getMinutes().toString().padStart(2, '0');
  return `${h}:${m}`;
}

function statusGlyph(s: MsgStatus): string {
  switch (s) {
    case MsgStatus.SENDING: return '···';
    case MsgStatus.SENT: return '✓';
    case MsgStatus.DELIVERED: return '✓✓';
    case MsgStatus.READ: return '✓✓';
    case MsgStatus.FAILED: return '!';
    default: return '';
  }
}

@Reusable
@Component
export struct MessageBubble {
  @ObjectLink msg: Msg;

  private bubbleFont(): Resource {
    return this.msg.outgoing ? Constants.C_FONT_ON_BRAND : Constants.C_FONT;
  }

  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.msg.text)
          .fontSize(14)
          .lineHeight(19)
          .fontColor(this.bubbleFont())

        Row({ space: 4 }) {
          Text(formatTime(this.msg.timestamp))
            .fontSize(10)
            .fontColor(this.msg.outgoing ? Constants.C_FONT_ON_BRAND : Constants.C_FONT_DIM)
            .opacity(this.msg.outgoing ? 0.7 : 1)

          if (this.msg.outgoing) {
            Text(statusGlyph(this.msg.status))
              .fontSize(10)
              .fontColor(this.msg.status === MsgStatus.FAILED ? Constants.C_WARNING : Constants.C_FONT_ON_BRAND)
              .opacity(this.msg.status === MsgStatus.READ ? 1 : 0.7)
          }
        }
        .alignSelf(ItemAlign.End)
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 10, right: 10, top: 6, bottom: 5 })
      .backgroundColor(this.msg.outgoing ? Constants.C_BRAND : Constants.C_SURFACE_ALT)
      .borderRadius(14)
      .constraintSize({ maxWidth: '82%' })
    }
    .width('100%')
    .justifyContent(this.msg.outgoing ? FlexAlign.End : FlexAlign.Start)
    .padding({ top: 2, bottom: 2 })
  }
}