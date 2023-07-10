# SmartPointers (Garbage collector simulator) for Delphi.
## This repo includes 7 different implementations of SmartPointers in Delphi to simulate a simple garbage collector.
In this way you will bind your objects to a reference counting supported object like an interface or a record and this object 
will automatically free the referenced object at the end of the scope.
You just create your object and don't worry about freeing anymore.


# There is a sample vcl app to demonstrate the usage.

## Simple Usage

### presumptive class
```delphi
  TPerson = class
    FName: string;
    FAge: Integer;
  public
    constructor Create; reintroduce; overload;
    constructor Create(const AName: string; const AAge: Integer); reintroduce; overload;
    destructor Destroy; override;
    procedure Birthday;
    property Name: string read FName write FName;
    property Age: integer read FAge write FAge;
  end;
```

### Version 1, 2, 3, 4 (usages are same but different implementations)
```delphi
var Person1: ISmartPointer1{or 2-4}<TPerson> := TSmartPointer1{or 2-4}<TPerson>.Create(TPerson.Create('Alex', 50));
 Person1.Ref.Birthday; // use the created object
 //done, no need to free the object.
```

### Version 5
```delphi
var
  LvPerson1: ISmartPointer5<TPerson>;
begin
  LvPerson1 := TSmartPointer5<TPerson>.Create(TPerson.Create('Person1', 45));
  LvPerson1.Birthday; // direct member access, do something with object.
  // done, no need to free.
end;
```

### Version 6
```delphi
var
  LvPerson1: TPerson;
begin
  LvPerson1 := SmartPointer6<TPerson>(TPerson.Create('Ali', 25));
  LvPerson1.Birthday;// do anything
  //done, no need to free.
end;
```

### Version 7
```delphi
var
  x: TSmartPointer7<TLifetimeWatcher>;
begin
  x := TLifetimeWatcher.Create(procedure begin ShowMessage('Destroying...'); end); // pass anonymouse method just for watching the life cycle of the object(it's not mandatory.)
  ShowMessage(X.Value.Birthday); // use the object.
  //done, noe need to free
end;
```
