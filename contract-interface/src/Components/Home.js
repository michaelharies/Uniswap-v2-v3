import { useEffect, useState } from "react";
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import Web3 from "web3";
import { my_accounts, rpc_goerli } from "../config/config";
import './Custom.css';
import FnPanel from "./FnPanel";
import FunctionTable from "./FunctionTable";

const Home = () => {

  const web3 = new Web3(rpc_goerli.https);
  const [contractAddr, setContractAddr] = useState('')
  const [contractAbi, setContractAbi] = useState([])
  const [contract, setContract] = useState({})
  const [selected, setSelectedFn] = useState([])
  const [fnIdx, setFnIdx] = useState([])
  const [encryptKey, setEncryptKey] = useState('')
  const [showLoader, setShowLoader] = useState(false)

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
      <div className="p-4 text-white text-center">
        <h1>Smart Contract UI</h1>
      </div>

      <div className="container mt-5">
        <div className="row">
          <div className="col-md-5 col-lg-6">
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
                setShowLoader={setShowLoader}
              />
            </div>
          </div>

        </div>
      </div>
      <div className={`loader ${showLoader ? "" : "d-none"}`} >
        <div className="container1">
          <div className="dash uno"></div>
          <div className="dash dos"></div>
          <div className="dash tres"></div>
          <div className="dash cuatro"></div>
        </div>
      </div>
      <ToastContainer />
    </>
  )
}

export default Home;