import { Variable } from "astal"

const time = Variable("").poll(1000, `date +'{"count":"%j","hour":"%H","minute":"%M","day":"%a %d/%m"}'`)

function Clock(): JSX.Element {
  return <overlay>
}

export default function Center() {
  return <box className="date" >
    Clock()
  </box>
}
