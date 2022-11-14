import { useEffect, useState } from "react";
import Web3 from "web3";
import FnPanel from "./FnPanel";
import FunctionTable from "./FunctionTable";
import { my_accounts, rpc_eth, rpc_goerli } from "../config/config"
import './Custom.css'

const Home = () => {

  const web3 = new Web3(rpc_goerli.https);
  const [contractAddr, setContractAddr] = useState('')
  const [contractAbi, setContractAbi] = useState([])
  const [contract, setContract] = useState({})
  const [selected, setSelectedFn] = useState([])
  const [fnIdx, setFnIdx] = useState([])
  const [encryptKey, setEncryptKey] = useState('')

  useEffect(() => {
    const _contract = new web3.eth.Contract(contractAbi, contractAddr, { from: my_accounts[0].public });
    setContract(_contract)
  }, [contractAbi, contractAddr])

  const getAbi = (abi) => {
    try {
      let newArr = []
      let ABI = JSON.parse(abi)
      let _writeActions = ABI.filter((method, index) => {
        if (method.type === 'function') {
          newArr.push(0)
          setFnIdx(newArr)
        }
				return method.type === "function" && (method.stateMutability === "payable" || method.stateMutability === "nonpayable");
      });
      setContractAbi(_writeActions);
    } catch (err) {
      console.log('err', err)
      setContractAbi([]);
      setFnIdx([])
    }
  }

  const changeSelectedFn = (_newAddr) => {
    setFnIdx(_newAddr)
    let _selected = contractAbi.filter((method, index) => {
      return _newAddr[index] === 1
    })
    setSelectedFn(_selected)
  }

  return (
    <>
      <div className="p-4 bg-primary text-white text-center">
        <h1>Smart Contract UI</h1>
      </div>

      <div className="container mt-5">
        <div className="row">
          <div className="col-md-5 col-lg-6">
            <p>Input Contract Address and ABI</p>
            <div className="container">
              <form className="form-inline bg-dark p-4 input-form">
                <div className="form-group row mb-3 ">
                  <label htmlFor="address" className="col-sm-2 col-form-label">Address</label>
                  <div className="col-sm-10">
                    <input type="text" className="form-control" id="address" placeholder="Contract address" onChange={(e) => setContractAddr(e.target.value)} required />
                  </div>
                </div>
                <div className="form-group row mb-3 ">
                  <label htmlFor="address" className="col-sm-2 col-form-label">Abi</label>
                  <div className="col-sm-10">
                    <textarea type="text" className="form-control" id="address" placeholder="Input contract abi" onChange={(e) => getAbi(e.target.value)} />
                  </div>
                </div>
                <div className="form-group row mb-3 ">
                  <label htmlFor="key" className="col-sm-2 col-form-label">Key</label>
                  <div className="col-sm-10">
                    <input type="text" className="form-control" id="key" placeholder="Encrypt Key" onChange={(e) => setEncryptKey(e.target.value)} />
                  </div>
                </div>
              </form>
            </div>
            <FunctionTable
              contractAbi={contractAbi}
              changeSelectedFn={changeSelectedFn}
              fnIdx={fnIdx}
            />
          </div>
          <div className="col-md-7 col-lg-6">
            <div className="row">
              <FnPanel
                contractAbi={contractAbi}
                fnIdx={fnIdx}
                changeSelectedFn={changeSelectedFn}
                contractAddr={contractAddr}
                contract={contract}
                web3={web3}
                my_accounts={my_accounts}
                encryptKey={encryptKey}
              />
            </div>
          </div>

        </div>
      </div>

      {/* <div className="mt-5 p-4 bg-dark text-white text-center">
        <p>@copyright 2022</p>
      </div> */}
    </>
  )
}

export default Home;