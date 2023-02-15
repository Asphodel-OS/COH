import React, { useState, useEffect, useCallback, useRef } from 'react';
import { map, merge } from 'rxjs';
import { EntityID, EntityIndex, Has, HasValue, NotValue, getComponentValue, runQuery } from "@latticexyz/recs";
import { registerUIComponent } from '../engine/store';
import { dataStore } from '../store/createStore';
import styled, { keyframes } from 'styled-components';
import './font.css';

import * as mqtt from "mqtt";

const mqttServerUrl = "wss://chatserver.asphodel.io:8083/mqtt";
const mqttTopic = "kamigotchi"

export function registerChat() {
  registerUIComponent(
    'Chat',
    {
      colStart: 65,
      colEnd: 99,
      rowStart: 5,
      rowEnd: 35,
    },

    (layers) => {
      const {
        network: {
          world,
          network,
          components: {
            IsOperator,
            OperatorID,
            PlayerAddress,
            Name
          },
        },
        phaser: {
          game: {
            scene: {
              keys: { Main },
            },
          },
        },
      } = layers;

      const getName = (index: EntityIndex) => {
        return getComponentValue(Name, index)?.value as string;
      }

      return merge(OperatorID.update$).pipe(
        map(() => {
          const operatorIndex = Array.from(runQuery([
            Has(IsOperator),
            HasValue(PlayerAddress, { value: network.connectedAddress.get() })
          ]))[0];
          const chatName = getName(operatorIndex);
          return {
            chatName: chatName
          }
        })
      )
    },

    ({ chatName }) => {

      type ChatMessage = { seenAt: number; message: string };

      const [messages, setMessages] = useState<ChatMessage[]>([]);
      const [chatInput, setChatInput] = useState("");

      const relay: mqtt.MqttClient = mqtt.connect(mqttServerUrl);

      useEffect(() => {
        const botElement = document.getElementById("botElement");

        const sub = relay.subscribe(mqttTopic, function (err: any) {
          if (!err) {
            postMessage("<[".concat( chatName, "] came online>"));
          }
        });

        const update_mqtt = () => {
          relay.on("message", function (topic: any, rawMessage: any) {
            const message = rawMessage.toString();
            console.log(message);
            setMessages((messages) => [...messages, { seenAt: Date.now(), message }]);
          });
          botElement?.scrollIntoView({behavior: "smooth", block: "start", inline: "start"})
        };
        update_mqtt();

        return () => {
          postMessage("<[".concat( chatName, "] went offline>"));
          sub.unsubscribe(mqttTopic, function (err: any) {});
        };
      }, []);

      const postMessage = useCallback(
        async (input: string) => {
          const botElement = document.getElementById("botElement");
          const message = `[${chatName}]: ${input}`;
          relay.publish(mqttTopic, message);
          setChatInput("");
          botElement?.scrollIntoView({behavior: "smooth", block: "start", inline: "start"})
        },
        []
      );

      const catchKeys = (event: React.KeyboardEvent<HTMLInputElement>) => {
        if (event.keyCode === 13) {
          postMessage(chatInput);
        }
        if (event.keyCode === 27) {
        }
      };

      const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        setChatInput(event.target.value);
      };

      const messageLines = messages.map((message) => (
        <li style={{ fontFamily: "Pixel", fontSize: "12px" }} key={message.seenAt}>
          {`${message.message}`}
        </li>
      ));

      const hideModal = () => {
        const modalId = window.document.getElementById('chat_modal');
        if (modalId) modalId.style.display = 'none';
      };

      const {
        objectData: { description },
      } = dataStore();

      return (
        <ModalWrapper id="chat_modal">
          <ModalContent>
            <TypeHeading>
              Chat
            </TypeHeading>
            <ChatWrapper>
              <ChatBox style={{ pointerEvents: 'auto'}}>
                { messageLines }
                <div id="botElement"> </div>
              </ChatBox>
              <ChatInput style={{ pointerEvents: 'auto'}}
                type="text"
                // onClick={() => disableEnableKeyBinds(false)}
                onKeyDown={(e) => catchKeys(e)}
                value={chatInput}
                onChange={(e) => handleChange(e)}
              />
            </ChatWrapper>
            <div style={{textAlign: "right"}}>
            <Button style={{ pointerEvents: 'auto'}} onClick={hideModal}>
              Close
            </Button>
            </div>
          </ModalContent>
        </ModalWrapper>
      );
    }
  );
}

const fadeIn = keyframes`
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
`;

const ChatWrapper = styled.div`
  background-color: #ffffff;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  color: black;
  padding: 15px 12px;

  text-align: left;
  text-decoration: none;
  display: inline-block;
  font-size: 12px;
  cursor: pointer;
  border-radius: 5px;
  justify-content: space-between;
  align-items: bottom;
  font-family: Pixel;
`

const ChatBox = styled.div`
  height: 200px;
  width: 100%;
  overflow: scroll;
  white-space: normal;
  word-wrap: break-word;
  padding: 10px 12px 25px 12px;
  cursor: pointer;
`

const ChatInput = styled.input`
  width: 100%;

  type: text
  background-color: #ffffff;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  color: black;
  padding: 15px 12px;
  box-shadow: 0 0 1px rgba(0, 0, 0, 0.3);

  text-align: left;
  text-decoration: none;
  display: inline-block;
  font-size: 12px;
  cursor: pointer;
  border-radius: 5px;
  justify-content: center;
  font-family: Pixel;
`

const ModalWrapper = styled.div`
  display: none;
  background-color: rgba(0, 0, 0, 0.5);
  justify-content: center;
  align-items: center;
  animation: ${fadeIn} 0.5s ease-in-out;
`;

const ModalContent = styled.div`
  display: flex;
  flex-direction: column;
  background-color: white;
  border-radius: 10px;
  box-shadow: 0 0 10px rgba(0, 0, 0, 0.3);
  padding: 20px;
  width: 99%;
  border-style: solid;
  border-width: 2px;
  border-color: black;
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

const KamiBox = styled.div`
  background-color: #ffffff;
  border-style: solid;
  border-width: 2px;
  border-color: black;
  color: black;
  text-decoration: none;
  display: grid;
  font-size: 18px;
  margin: 3px 2px;
  border-radius: 5px;
  font-family: Pixel;
`;

const KamiFacts = styled.div`
  background-color: #ffffff;
  color: black;
  font-size: 18px;
  margin: 0px;
  padding: 0px;
  grid-column: 2 / span 1000;
`;

const Description = styled.p`
  font-size: 16px;
  color: #333;
  text-align: left;
  padding: 20px;
  font-family: Pixel;
`;

const TypeHeading = styled.p`
  font-size: 20px;
  color: #333;
  text-align: left;
  padding: 20px;
  font-family: Pixel;
`;

const KamiImage = styled.img`
  border-style: solid;
  border-width: 0px 2px 0px 0px;
  border-color: black;
  height: 90px;
  margin: 0px;
  padding: 0px;
  grid-column: 1 / span 1;
`;
