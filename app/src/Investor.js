import React from "react";
import { drizzleReactHooks } from "@drizzle/store";
import { newContextComponents } from "@drizzle/react-components";

const { useDrizzle, useDrizzleState } = drizzleReactHooks;
const { ContractData, ContractForm } = newContextComponents;

// eslint-disable-next-line import/no-anonymous-default-export
export default () => {
  const { drizzle } = useDrizzle();
  const state = useDrizzleState((state) => state);

  return (
    <div>
      <div>
        <h2>Investment (token) </h2>
        <ContractData
          drizzle={drizzle}
          drizzleState={state}
          contract="ICO"
          method="getSale"
          methodArgs={[state.accounts[0]]}
        />
      </div>
      <div>
        <h2>Buy (token) </h2>
        <ContractForm drizzle={drizzle} contract="ICO" method="buy" />
      </div>
    </div>
  );
};
