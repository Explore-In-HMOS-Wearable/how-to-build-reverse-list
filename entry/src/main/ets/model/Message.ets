export enum MsgStatus {
  SENDING = 0,
  SENT = 1,
  DELIVERED = 2,
  READ = 3,
  FAILED = 4
}

@Observed
export class Msg {
  readonly id: string;
  readonly text: string;
  readonly outgoing: boolean;
  readonly timestamp: number;
  status: MsgStatus;

  constructor(id: string, text: string, outgoing: boolean,
    timestamp: number = Date.now(),
    status: MsgStatus = MsgStatus.SENT) {
    this.id = id;
    this.text = text;
    this.outgoing = outgoing;
    this.timestamp = timestamp;
    this.status = status;
  }
}