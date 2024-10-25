open Belt

%raw(`require("./PropertiesPanel.css")`)
%raw(`require("./index.css")`)

module Collapsible = {
  @react.component
  let make = (~title, ~children) => {
    let (collapsed, toggle) = React.useState(() => false)

    <section className="Collapsible">
      <button className="Collapsible-button" onClick={_e => toggle(_ => !collapsed)}>
        <span> {React.string(title)} </span> <span> {React.string(collapsed ? "+" : "-")} </span>
      </button>
      {collapsed ? React.null : <div className="Collapsible-content"> {children} </div>}
    </section>
  }
}

// This component provides a simplified example of fetching JSON data from
// the backend and rendering it on the screen.
module ViewExamples = {
  // Type of the data returned by the /examples endpoint
  type example = {
    id: int,
    some_int: int,
    some_text: string,
  }

  @react.component
  let make = () => {
    let (examples: option<array<example>>, setExamples) = React.useState(_ => None)

    React.useEffect1(() => {
      // Fetch the data from /examples and set the state when the promise resolves
      Fetch.fetchJson(`http://localhost:12346/examples`)
      |> Js.Promise.then_(examplesJson => {
        // NOTE: this uses an unsafe type cast, as safely parsing JSON in rescript is somewhat advanced.
        Js.Promise.resolve(setExamples(_ => Some(Obj.magic(examplesJson))))
      })
      // The "ignore" function is necessary because each statement is expected to return `unit` type, but Js.Promise.then return a Promise type.
      |> ignore
      None
    }, [setExamples])

    <div>
      {switch examples {
      | None => React.string("Loading examples....")
      | Some(examples) =>
        examples
        ->Js.Array2.map(example =>
          React.string(`Int: ${example.some_int->Js.Int.toString}, Str: ${example.some_text}`)
        )
        ->React.array
      }}
    </div>
  }
}

module DimensionInput = {
  @react.component
  let make = (~value, ~onBlur, ~unit, ~onChange, ~onUnitChange, ~dimensionKey) => {
    let (isFocused, setIsFocused) = React.useState(() => false)

    // LLM generated regex validation to ensure only numbers are inputted
    let handleKeyDown = event => {
      let key = ReactEvent.Keyboard.key(event)
      let allowedCharactersRegex = %re("/[0-9]|Backspace|Delete|ArrowLeft|ArrowRight/")

      if !Js.Re.test_(allowedCharactersRegex, key) {
        ReactEvent.Keyboard.preventDefault(event)
      }
    }

    <div
      className={`Dimension-input-container ${!isFocused && value !== "auto"
          ? "Dimension-input-container--active"
          : ""}`}
      onFocus={_ => setIsFocused(_ => true)}
      onMouseDown={event => {
        ReactEvent.Mouse.stopPropagation(event)
        ReactEvent.Mouse.preventDefault(event)
      }}
      onBlur={_ => setIsFocused(_ => false)}>
      <input
        className={`Dimension-input ${!isFocused && value !== "auto"
            ? "Dimension-input--active"
            : ""}`}
        onClick={event => {
          let input = ReactEvent.Mouse.currentTarget(event)
          input["select"](.)
        }}
        onBlur={event => {
          onBlur(~key=dimensionKey, ~newValue=ReactEvent.Focus.target(event)["value"])
        }}
        value
        onChange={event =>
          onChange(~key=dimensionKey, ~newValue=ReactEvent.Form.target(event)["value"])}
        onKeyDown={handleKeyDown}
      />
      {
        // Causes some  Layout shift, can solve this with opacity or by placing the button in the input, but judged this wasn't a showstopper for a demo
        isFocused || value !== "auto"
          ? <button
              className="Dimension-button"
              disabled={!isFocused}
              onClick={_ => onUnitChange(~key=dimensionKey)}>
              {unit->React.string}
            </button>
          : React.null
      }
    </div>
  }
}

module DimensionHandlers = {
  type dimensions = {
    top: string,
    bottom: string,
    left: string,
    right: string,
    top_unit: string,
    bottom_unit: string,
    left_unit: string,
    right_unit: string,
  }

  let createInitialState = () => {
    top: "auto",
    bottom: "auto",
    left: "auto",
    right: "auto",
    top_unit: "px",
    bottom_unit: "px",
    left_unit: "px",
    right_unit: "px",
  }

  let handleChange = (~key: string, ~newValue: string, ~dimensions, ~setDimensions) => {
    // Naive validation to prevent the user from entering a number greater than 9999
    let validatedValue = Belt.Int.fromString(newValue) > Some(9999) ? "9999" : newValue
    setDimensions(prevDimensions =>
      switch key {
      | "top" => {...prevDimensions, top: validatedValue}
      | "bottom" => {...prevDimensions, bottom: validatedValue}
      | "left" => {...prevDimensions, left: validatedValue}
      | "right" => {...prevDimensions, right: validatedValue}
      | _ => prevDimensions
      }
    )
  }

  // Semi-hacky way to ensure that our blank input only reverts to "auto" when the user clicks away from it. If I did it in handleChange, it would revert to "auto" on every keystroke when the input is blank.
  let handleBlur = (~key: string, ~newValue: string, ~dimensions, ~setDimensions) => {
    let value = newValue === "" ? "auto" : newValue

    setDimensions(prevDimensions =>
      switch key {
      | "top" => {...prevDimensions, top: value}
      | "bottom" => {...prevDimensions, bottom: value}
      | "left" => {...prevDimensions, left: value}
      | "right" => {...prevDimensions, right: value}
      | _ => prevDimensions
      }
    )
  }

  // purposefully only accepts px or % , if more formats were used this would change from a button to a dropdown
  let handleUnitChange = (~key: string, ~dimensions, ~setDimensions) => {
    setDimensions(prevDimensions =>
      switch key {
      | "top" => {...prevDimensions, top_unit: prevDimensions.top_unit === "px" ? "%" : "px"}
      | "bottom" => {
          ...prevDimensions,
          bottom_unit: prevDimensions.bottom_unit === "px" ? "%" : "px",
        }
      | "left" => {...prevDimensions, left_unit: prevDimensions.left_unit === "px" ? "%" : "px"}
      | "right" => {
          ...prevDimensions,
          right_unit: prevDimensions.right_unit === "px" ? "%" : "px",
        }
      | _ => prevDimensions
      }
    )
  }
}

module PaddingSelector = {
  type padding = DimensionHandlers.dimensions
  @react.component
  let make = () => {
    let (padding, setPadding) = React.useState(() => DimensionHandlers.createInitialState())

    let handleChange = (~key: string, ~newValue: string) =>
      DimensionHandlers.handleChange(
        ~key,
        ~newValue,
        ~dimensions=padding,
        ~setDimensions=setPadding,
      )

    let handleBlur = (~key: string, ~newValue: string) =>
      DimensionHandlers.handleBlur(~key, ~newValue, ~dimensions=padding, ~setDimensions=setPadding)

    let handleUnitChange = (~key: string) =>
      DimensionHandlers.handleUnitChange(~key, ~dimensions=padding, ~setDimensions=setPadding)

    <div className="PaddingSelector-container">
      <div className="Dimension-centered">
        <DimensionInput
          value={padding.top}
          unit={padding.top_unit}
          onBlur={handleBlur}
          onChange={handleChange}
          onUnitChange={handleUnitChange}
          dimensionKey="top"
        />
      </div>
      <div className="Selector-row">
        <DimensionInput
          value={padding.left}
          unit={padding.left_unit}
          onBlur={handleBlur}
          onChange={handleChange}
          onUnitChange={handleUnitChange}
          dimensionKey="left"
        />
        <DimensionInput
          value={padding.right}
          unit={padding.right_unit}
          onBlur={handleBlur}
          onChange={handleChange}
          onUnitChange={handleUnitChange}
          dimensionKey="right"
        />
      </div>
      <div className="Dimension-centered">
        <DimensionInput
          value={padding.bottom}
          unit={padding.bottom_unit}
          onBlur={handleBlur}
          onChange={handleChange}
          onUnitChange={handleUnitChange}
          dimensionKey="bottom"
        />
      </div>
    </div>
  }
}

module MarginSelector = {
  @react.component
  let make = () => {
    let (margin, setMargin) = React.useState(() => DimensionHandlers.createInitialState())

    let handleChange = (~key: string, ~newValue: string) => {
      Js.log("handleChange")
      DimensionHandlers.handleChange(~key, ~newValue, ~dimensions=margin, ~setDimensions=setMargin)
    }

    let handleBlur = (~key: string, ~newValue: string) => {
      DimensionHandlers.handleBlur(~key, ~newValue, ~dimensions=margin, ~setDimensions=setMargin)
    }

    let handleUnitChange = (~key: string) =>
      DimensionHandlers.handleUnitChange(~key, ~dimensions=margin, ~setDimensions=setMargin)

    <div className="MarginSelector-container">
      <div className="MarginSelector-subwrapper">
        <div className="Dimension-centered">
          <DimensionInput
            value={margin.top}
            unit={margin.top_unit}
            onBlur={handleBlur}
            onChange={handleChange}
            onUnitChange={handleUnitChange}
            dimensionKey="top"
          />
        </div>
        <div className="Selector-row">
          <DimensionInput
            value={margin.left}
            unit={margin.left_unit}
            onBlur={handleBlur}
            onChange={handleChange}
            onUnitChange={handleUnitChange}
            dimensionKey="left"
          />
          <DimensionInput
            value={margin.right}
            unit={margin.right_unit}
            onBlur={handleBlur}
            onChange={handleChange}
            onUnitChange={handleUnitChange}
            dimensionKey="right"
          />
        </div>
        <div className="Dimension-centered">
          <DimensionInput
            value={margin.bottom}
            unit={margin.bottom_unit}
            onBlur={handleBlur}
            onChange={handleChange}
            onUnitChange={handleUnitChange}
            dimensionKey="bottom"
          />
        </div>
        <PaddingSelector />
      </div>
    </div>
  }
}

@genType @genType.as("PropertiesPanel") @react.component
let make = () => {
  <aside className="PropertiesPanel">
    <Collapsible title="Load examples"> <ViewExamples /> </Collapsible>
    <Collapsible title="Margins & Padding"> <MarginSelector /> </Collapsible>
    <Collapsible title="Size"> <span> {React.string("example")} </span> </Collapsible>
  </aside>
}
