import React, { useState, useEffect } from "react";
import { drizzleReactHooks } from "@drizzle/store";
import { newContextComponents } from "@drizzle/react-components";

const { useDrizzle, useDrizzleState } = drizzleReactHooks;
const { ContractForm } = newContextComponents;

// eslint-disable-next-line import/no-anonymous-default-export
export default () => {
  const [isAdmin, setIsAdmin] = useState(undefined);
  const { drizzle } = useDrizzle();
  const state = useDrizzleState((state) => state);

  useEffect(() => {
    const init = async () => {
      const admin = await drizzle.contracts.ICO.methods.admin().call();
      setIsAdmin(admin.toLowerCase() === state.accounts[0].toLowerCase());
    };
    init();
  }, []);

  if (!isAdmin) {
    return null;
  }

  return (
    <div>
      <div>
        <h2>Start</h2>
        <ContractForm drizzle={drizzle} contract="ICO" method="start" />
      </div>
      <div>
        <h2>Whitelist</h2>
        <ContractForm drizzle={drizzle} contract="ICO" method="whitelist" />
      </div>
      <div>
        <h2>Release Tokens</h2>
        <ContractForm drizzle={drizzle} contract="ICO" method="release" />
      </div>
      <div>
        <h2>Withdraw</h2>
        <ContractForm drizzle={drizzle} contract="ICO" method="withdraw" />
      </div>
    </div>
  );
};
