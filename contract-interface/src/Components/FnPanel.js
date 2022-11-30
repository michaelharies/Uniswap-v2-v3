import { useState } from 'react';
import { toast } from 'react-toastify';
import './Custom.css';
import { ethers } from 'ethers'

var bigInt = require("big-integer");

const goerli_middleTokens = {
  dai: "0xdc31ee1784292379fbb2964b3b9c4124d8f89c60",
  uni: "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
  usdc: "0xD87Ba7A50B2E7E660f678A895E4B72E7CB4CCd9C",
  none: "0x0000000000000000000000000000000000000000"
}

const mainnet_middleToken = {
  dai: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
  uni: "0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984",
  usdc: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
  none: "0x0000000000000000000000000000000000000000"
}

const setFn_names = [
  'setBulkExact',
  'setBulkFomo',
  'setFomo',
  'setMulticall',
  'setSwap',
  'setSwapNormal2',
  'setSwapNormalSellTip'
];
const _data = [];

const FnPanel = ({ contractAbi, fnIdx, changeSelectedFn, contractAddr, contract, web3, my_accounts, encryptKey, setShowLoader, gasPrice, gasLimit }) => {

  const [form, setForm] = useState({
    setPairToken: "0x6B175474E89094C44Da98b954EedeAC495271d0F",
    setRouterAddress: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
    bSellTest: false
  });
  const [pending, setPending] = useState(false)

  const selectFn = async (_key) => {
    fnIdx[_key] = 0;
    changeSelectedFn(fnIdx);
  }

  const _onChange = (e) => {
    let name = e.target.name
    let value = e.target.value
    let param_type = e.target.dataset.type
    let fn_type = e.target.dataset.fntype

    let arrayParams = (value.replace(/[^0-9a-z-A-Z ,]/g, "").replace(/ +/, " ")).split(",")
    if (param_type.substr(-2) === '[]') {
      let values = [];
      for (var i = 0; i < arrayParams.length; i++) {
        values.push(arrayParams[i])
      }
      setForm(state => ({ ...state, [name]: values }));
    } else if (param_type === 'bool') {
      if (value === 'true') setForm(state => ({ ...state, [name]: true }));
      else setForm(state => ({ ...state, [name]: false }));
    } else {
      setForm(state => ({ ...state, [name]: value }));
    }
    if (setFn_names.includes(fn_type)) {
      if (encryptKey === '') {
        alert('please input encrypt key');
      }
      let _key = bigInt(encryptKey.substr(2), 16)
      if (name === 'token' || name === 'tokenToBuy') {
        let _value = _key.value ^ bigInt(value.substr(2), 16).value;
        console.log('value', _value)
        setForm(state => ({ ...state, [name]: _value }));
      }
    }
  }

  const clickFn = async (e) => {
    if (pending) {
      alert('please wait for while...')
      return;
    }
    setPending(true)
    _data[e.target.value] = toast.loading(`${e.target.value} is pending....`);
    let params = [];
    contractAbi?.map((currentFn, key) => {
      if (currentFn.name === e.target.name) {
        currentFn.inputs.map((inputs, key) => {
          params.push(form[inputs.name])
        })
      }
    })
    console.log('params', params)
    try {
      const tx = contract.methods[e.target.name](...params);
      let _gasLimit = await tx.estimateGas()
      let _gasPrice = await web3.eth.getGasPrice()
      let nonce = await web3.eth.getTransactionCount(my_accounts[0].public, "pending")
      if (gasLimit < _gasLimit || gasPrice < _gasPrice / 10 ** 9) {
        let confirm = window.confirm(`You set low Gas Price or Gas Limit than default. \nIt will take some time to confirm this tx. \nExpected values: \nGas Price: ${_gasPrice / 10 ** 9}, Gas Limit: ${_gasLimit}`)
        if (!confirm) {
          setPending(false)
          toast.update(
            _data[e.target.value],
            {
              render: `Declined Tx for ${e.target.value}`,
              type: "warn",
              isLoading: false,
              closeButton: true,
              autoClose: 5000,
              pauseOnFocusLoss: false
            });
          return
        }
      }
      let txdata = {
        to: contractAddr,
        type: 0,
        data: tx.encodeABI(),
        nonce: nonce,
        gas: gasLimit,
        gasPrice: web3.utils.toWei(gasPrice.toString(), 'gwei')
      }
      const createTransaction = await web3.eth.accounts.signTransaction(txdata, my_accounts[0].private);
      setPending(false)
      toast.update(
        _data[e.target.value],
        {
          render: `${e.target.value} is pending.... hash: ${createTransaction.transactionHash}`,
          type: "success",
          isLoading: true,
          className: 'rotateY animated',
          closeButton: true,
          pauseOnFocusLoss: false
        });
      const txRes = await web3.eth.sendSignedTransaction(createTransaction.rawTransaction);
      console.log('tx res', txRes)
      if (txRes) {
        setShowLoader(false)
        toast.update(
          _data[e.target.value],
          {
            render: `Successfully ${e.target.value}.`,
            type: "success",
            isLoading: false,
            autoClose: 5000,
            className: 'rotateY animated',
            closeButton: true, pauseOnFocusLoss: false
          });
      }
    } catch (err) {
      setPending(false)
      toast.update(_data[e.target.value], { render: `Failed!! ${e.target.value}`, type: "error", isLoading: false, closeButton: true, autoClose: 5000 });
      console.log('err', err)
    }
  }

  return (
    <>
      {contractAbi?.map((item, key) => {
        return (
          <div className={`col-sm-12 p-3 bg-dark mb-4 fn-panel ${fnIdx[key] === 1 ? "" : "d-none"}`} key={key}>
            <div className="d-flex justify-content-between px-3 fn-title">
              <div className="fn-name">{item.name}</div>
              <div className="close" onClick={() => selectFn(key)}>x</div>
            </div>
            {item.inputs && item.inputs.map((input, key1) => {
              if (input.name === 'setPairToken') {
                return (
                  <div key={key1}>
                    <div className="form-floating mb-3 mt-3" >
                      <select className="form-select" id={input.name} name={input.name} data-type={input.type} data-fntype={item.name} onChange={(e) => _onChange(e)}>
                        <option value={goerli_middleTokens.dai}>DAI</option>
                        <option value={goerli_middleTokens.uni}>UNI</option>
                        <option value={goerli_middleTokens.usdc}>USDC</option>
                        <option value={goerli_middleTokens.none}>None</option>
                      </select>
                      <label htmlFor={input.name}>{input.name}({input.type})</label>
                    </div>
                  </div>
                )
              } else if (input.name == 'setRouterAddress') {
                return (
                  <div key={key1}>
                    <div className="form-floating mb-3 mt-3" >
                      <select className="form-select" id={input.name} name={input.name} data-type={input.type} data-fntype={item.name} onChange={(e) => _onChange(e)}>
                        <option value="0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D">Uniswap V2 (0x7a25...488D)</option>
                        <option value="0xE592427A0AEce92De3Edee1F18E0157C05861564">Uniswap V3 (0xE592...1564)</option>
                      </select>
                      <label htmlFor={input.name}>{input.name}({input.type})</label>
                    </div>
                  </div>
                )
              } else if (input.name === 'times' || input.name === 'repeat') {
                return (
                  <div key={key1}>
                    <div className="form-floating mb-3 mt-3" >
                      <input type="number" className="form-control" id={input.name} placeholder={input.type} name={input.name} data-type={input.type} data-fntype={item.name} onChange={(e) => _onChange(e)} />
                      <label htmlFor={input.name}>{input.name}({input.type})</label>
                    </div>
                  </div>
                )
              } else if (input.name === 'bSellTest') {
                return (
                  <div key={key1}>
                    <div className="form-floating mb-3 mt-3" >
                      <select className="form-select" id={input.name} name={input.name} data-type={input.type} data-fntype={item.name} onChange={(e) => _onChange(e)}>
                        <option value="false">FALSE</option>
                        <option value="true">TRUE</option>
                      </select>
                      <label htmlFor={input.name}>{input.name}({input.type})</label>
                    </div>
                  </div>
                )
              }
              else {
                return (
                  <div key={key1}>
                    <div className="form-floating mb-3 mt-3" >
                      <input type="text" className="form-control" id={input.name} placeholder={input.type} name={input.name} data-type={input.type} data-fntype={item.name} onChange={(e) => _onChange(e)} />
                      <label htmlFor={input.name}>{input.name}({input.type})</label>
                    </div>
                  </div>
                )
              }
            }
            )}
            <div className="input-group py-3">
              <input type="button" className="btn btn-success w-100 mx-3" value={item.name} name={item.name} onClick={(e) => clickFn(e)} />
            </div>
            <hr className="d-sm-none" />
          </div>
        )
      })}
    </>
  )
}

export default FnPanel;