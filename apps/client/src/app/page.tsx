import adder from "@d2n/adder";


export default function Home() {
  return (
        <main className="flex min-h-screen flex-col items-center justify-between p-24">
            <h1> Hello: {adder(1, 2)} </h1>
        </main>
    )
}
