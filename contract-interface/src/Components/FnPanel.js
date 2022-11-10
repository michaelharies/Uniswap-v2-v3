import './Custom.css';

const FnPanel = ({ contractAbi, fnIdx, changeSelectedFn }) => {

  const selectFn = (_key) => {
    fnIdx[_key] = 0;
    changeSelectedFn(fnIdx);
  }

  return (
    <>
      {contractAbi?.map((item, idx) => {
        return (
          <div className={`col-sm-12 p-3 bg-dark mb-4 fn-panel ${fnIdx[idx] === 1 ? "" : "d-none"}`} key={idx}>
            <div className="d-flex justify-content-between px-3 fn-title">
              <div className="fn-name">{item.name}</div>
              <div className="close" onClick={() => selectFn(idx)}>x</div>
            </div>
            {item.inputs && item.inputs.map((input, key) => {
              return (
                <>
                  <div className="form-floating mb-3 mt-3" key={key}>
                    <input type="text" className="form-control" id={input.name} placeholder={input.type} name={input.name} required />
                    <label htmlFor={input.name}>{input.name}({input.type})</label>
                  </div>
                </>
              )
            }
            )}
            <div className="input-group py-3">
              <input type="button" className="btn btn-primary form-control mx-3" value={item.name} />
            </div>
            <hr className="d-sm-none" />
          </div>
        )
      })}
    </>
  )
}

export default FnPanel;