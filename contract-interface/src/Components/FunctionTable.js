import './Custom.css';

const FunctionTable = ({ contractAbi, changeSelectedFn, fnIdx }) => {
  
  const selectFn = async(_key) => {
    fnIdx[_key] = 1;
    changeSelectedFn(fnIdx);
  }

  return (
    <div className="container mt-3">
      <table className="table table-dark table-responsive-md fn-table text-center">
        <thead>
          <tr>
            <th scope='row'>No</th>
            <th>Name</th>
          </tr>
        </thead>
        <tbody>
          {
            contractAbi?.map((functions, key) => {
              return (
                <tr className='fn-row' key={key}>
                  <td>{key}</td>
                  <td className="fn-name" onClick={() => {
                    selectFn(key)
                  }
                  } >{functions.name}</td>
                </tr>
              )
            })
          }
        </tbody>
      </table>
    </div>
  )
}

export default FunctionTable;