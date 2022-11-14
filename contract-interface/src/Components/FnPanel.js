import { useState } from 'react';
import './Custom.css';
var bigInt = require("big-integer");

const FnPanel = ({ contractAbi, fnIdx, changeSelectedFn, contractAddr, contract, web3, my_accounts, encryptKey }) => {

  const [form, setForm] = useState({});

  const selectFn = (_key) => {
    fnIdx[_key] = 0;
    changeSelectedFn(fnIdx);
  }

  const _onChange = (e) => {
    let name = e.target.name
    let value = e.target.value
    let param_type = e.target.dataset.type
    let fn_type = e.target.dataset.fntype
  
    if (fn_type === 'swapExactTokenForToken') {
      console.log(param_type, name, value, typeof value)
      if (encryptKey === '') {
        alert('please input encrypt key');
        return
      }
      if (name === 'amountIn' || name === 'amountOut') {
        let _value = bigInt(encryptKey) ^ bigInt(value);
        console.log('_value', _value)
        setForm(state => ({ ...state, [name]: _value }));
      } else {
        let arrayParams = (value.replace(/[^0-9a-z-A-Z ,]/g, "").replace(/ +/, " ")).split(",")
        arrayParams.map(x => {
          let _value = bigInt(encryptKey)  ^ bigInt(x.substr(2));
          console.log(_value)
          setForm(state => ({ ...state, [name]: _value }));
        })
      }
    } else {
      setForm(state => ({ ...state, [name]: value }));
    }
  }

  const clickFn = async (e) => {
    let params = [];
    contractAbi?.map((currentFn, key) => {
      if (currentFn.name === e.target.name) {
        currentFn.inputs.map((inputs, key) => {
          params.push(form[inputs.name])
        })
      }
    })
    try {
      const tx = contract.methods[e.target.name](...params);
      let gas = await tx.estimateGas()
      let gasPrice = await web3.eth.getGasPrice()
      let txdata = {
        to: contractAddr,
        type: 0,
        data: tx.encodeABI(),
        gas: gas,
        gasPrice: gasPrice,
        nonce: await web3.eth.getTransactionCount(my_accounts[0].public)
      }
      const createTransaction = await web3.eth.accounts.signTransaction(txdata, my_accounts[0].private);
      const txRes = await web3.eth.sendSignedTransaction(createTransaction.rawTransaction);
      console.log('tx res', txRes)
      // let res = await txRes.wait();
      // console.log('res', res)
    } catch (err) {
      console.log('err', err)
    }
  }

  return (
    <>
      {contractAbi?.map((item, idx) => {
        return (
          <div className={`col-sm-12 p-3 bg-dark mb-4 fn-panel ${fnIdx[idx] === 1 ? "" : "d-none"}`} idx={idx}>
            <div className="d-flex justify-content-between px-3 fn-title">
              <div className="fn-name">{item.name}</div>
              <div className="close" onClick={() => selectFn(idx)}>x</div>
            </div>
            {item.inputs && item.inputs.map((input, key) => {
              return (
                <>
                  <div className="form-floating mb-3 mt-3" key={key}>
                    <input type="text" className="form-control" id={input.name} placeholder={input.type} name={input.name} data-type={input.type} data-fnType={item.name} onChange={(e) => _onChange(e)} required />
                    <label htmlFor={input.name}>{input.name}({input.type})</label>
                  </div>
                </>
              )
            }
            )}
            <div className="input-group py-3">
              <input type="button" className="btn btn-primary form-control mx-3" value={item.name} name={item.name} onClick={(e) => clickFn(e)} />
            </div>
            <hr className="d-sm-none" />
          </div>
        )
      })}
    </>
  )
}

export default FnPanel;