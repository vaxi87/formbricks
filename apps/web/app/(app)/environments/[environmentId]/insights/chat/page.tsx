"use client";

import { useChat } from "ai/react";
import { Input } from "@formbricks/ui/Input";

export default function Chat() {
  const { messages, input, handleInputChange, handleSubmit } = useChat();
  return (
    <div className="stretch mx-auto flex w-full max-w-md flex-col py-24">
      <div className="flex flex-col space-y-4">
        {messages.map((m) => (
          <div key={m.id} className="overflow-hidden rounded-lg bg-white shadow">
            <div className="px-4 py-5 sm:px-6">{m.role === "user" ? "You" : "AI"}</div>
            <div className="bg-gray-50 px-4 py-5 sm:p-6"> {m.content}</div>
          </div>
        ))}
      </div>

      <div className="fixed bottom-0 flex justify-center rounded-lg border border-slate-200 bg-white p-4 shadow-lg">
        <form onSubmit={handleSubmit} className="flex w-96">
          <Input
            className="mb-8 w-full max-w-md"
            value={input}
            placeholder="Ask something..."
            onChange={handleInputChange}
          />
        </form>
      </div>
    </div>
  );
}
