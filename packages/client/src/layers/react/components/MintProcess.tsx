import React, { useState } from 'react';
import { of } from 'rxjs';
import { registerUIComponent } from '../engine/store';
import styled, { keyframes } from 'styled-components';

export function registerMintProcess() {
  registerUIComponent(
    'MintProcess',
    {
      colStart: 40,
      colEnd: 60,
      rowStart: 40,
      rowEnd: 70,
    },
    (layers) => of(layers),

    () => {
      const hideMint = () => {
        document.getElementById('mint_process')!.style.display = 'none';
      };
      const [mintSuccess, setMintSuccess] = useState(false);

      setTimeout(() => {
        setMintSuccess(true);
      }, 7000);

      return (
        <ContainerWrapper>
          <MintContainer id="mint_process" style={{ display: 'none' }}>
            {!mintSuccess ? (
              <MintProcess>Loading...</MintProcess>
            ) : (
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'center',
                  flexDirection: 'column',
                }}
              >
                <div style={{ textAlign: 'center' }}>
                  <MintSuccess>Welcome to Kamigotchi World!</MintSuccess>
                  <Button style={{ pointerEvents: 'auto' }} onClick={hideMint}>
                    Okay
                  </Button>
                </div>
              </div>
            )}
          </MintContainer>
        </ContainerWrapper>
      );
    }
  );
}

const rotate = keyframes`
  0% {
    transform: rotate(0deg);
  }
  50% {
    transform: rotate(-180deg);
  }
  100% {
    transform: rotate(360deg);
  }
`;

const ContainerWrapper = styled.div`
  background-color: rgba(0, 0, 0, 0.5);
  justify-content: center;
  align-items: center;
`;

const MintContainer = styled.div`
  display: flex;
  width: 100%;
  height: 100%;
  background-color: #ffffff;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border-radius: 10px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.3);
  padding: 20px;
  width: 99%;
  border-style: solid;
  border-width: 2px;
  border-color: black;
`;

const MintProcess = styled.div`
  animation: ${rotate} 3s ease-in-out infinite;
  color: black;
  font-family: Pixel;
  padding: 20px;
  font-size: 18px;
`;

const MintSuccess = styled.div`
  display: 'block';
  font-size: 18px;
  color: green;
  font-family: Pixel;
  padding: 20px;
`;

const Button = styled.button`
  background-color: #ffffff;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  color: black;
  padding: 15px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 18px;
  margin: 4px 2px;
  cursor: pointer;
  border-radius: 5px;
  justify-content: center;
  font-family: Pixel;
`;
