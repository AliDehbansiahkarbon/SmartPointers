unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Generics.Collections, USmartPointers;

type
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
  {$IF CompilerVersion >= 34.0}
  TPersons = class(TRefCountable)
    FName: string;
    FAge: Integer;
  public
    constructor Create(const AName: string; const AAge: Integer); reintroduce;
    destructor Destroy; override;
    procedure Birthday;
    property Name: string read FName write FName;
    property Age: integer read FAge write FAge;
  end;
  {$ENDIF}
  TForm1 = class(TForm)
    Btn_SmartPointer1: TButton;
    Btn_SmartPoniter5: TButton;
    Btn_Classic: TButton;
    Btn_SmartPointer2: TButton;
    Btn_SmartPointer3: TButton;
    Btn_SmartPointer4: TButton;
    Btn_SmartPoniter6: TButton;
    Btn_SmartPoniter7: TButton;
    procedure Btn_ClassicClick(Sender: TObject);
    procedure Btn_SmartPointer1Click(Sender: TObject);
    procedure Btn_SmartPointer2Click(Sender: TObject);
    procedure Btn_SmartPointer3Click(Sender: TObject);
    procedure Btn_SmartPointer4Click(Sender: TObject);
    procedure Btn_SmartPoniter5Click(Sender: TObject);
    procedure Btn_SmartPoniter6Click(Sender: TObject);
    procedure Btn_SmartPoniter7Click(Sender: TObject);
  private
  public
  end;

  // Smart pointer param
  procedure ShowName(APerson: ISmartPointer5<TPerson>);
  // TPerson param
  procedure ShowAge(APerson: TPerson);

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure ShowName(APerson: ISmartPointer5<TPerson>);
begin
  ShowMessage(APerson.Name);
end;

procedure ShowAge(APerson: TPerson);
begin
  ShowMessage(APerson.Age.ToString);
end;

procedure TForm1.Btn_SmartPointer1Click(Sender: TObject);
{$IF CompilerVersion < 34.0}
var
  Ali, Alex: ISmartPointer1<TPerson>;
{$ENDIF}
begin
  {$IF CompilerVersion >= 34.0}
  var Ali: ISmartPointer1<TPerson> := TSmartPointer1<TPerson>.Create(TPerson.Create('Ali', 50));
  {$ELSE}
    Ali := TSmartPointer1<TPerson>.Create(TPerson.Create('Ali', 50));
  {$ENDIF}
  { Now the smart pointer has a reference count of 1.}


  {*******************************************************************************************}
  {  Important note! you cannot use type inference to create an instance of the smart pointer.}
  {  so this code is wrong:                                                                   }
  {  var List1 := TSmartPointer1<TPerson>.Create(TPerson.Create);                             }
  {  This will make List1 of type TSmartPointer1<> instead of ISmartPointer1<>                }
  {  resulting in two memory leaks                                                            }
  { (for the TSmartPointer1<> object itself and for the TPerson).                             }
  {*******************************************************************************************}

  Ali.Ref.Age := Ali.Ref.Age + 1;
  Ali.Ref.Birthday;

  {$IF CompilerVersion >= 34.0}
  var Alex := Ali;
  {$ELSE}
  Alex := Ali;
  {$ENDIF}

  Alex.Ref.Name := 'Alex';
  {if I copy the smart pointer, it's OK and it will have a reference count of 2 now.}


  { Check contents of List2 }
  Assert(Alex.Ref.Name = 'Alex');
  Assert(Alex.Ref.Age = 51);

  { List2 will go out of scope here, so only List1
    will keep a reference to the TStringList.
    The reference count will be reduced to 1. }

  { Check contents of List1 again }
  Assert(Ali.Ref.Age = 51);

  { Now List1 will go out of scope, reducing the
    reference count to 0 and destroying the TStringList. }
end;

procedure TForm1.Btn_SmartPointer2Click(Sender: TObject);
begin
 {$IF CompilerVersion >= 34.0}
  var Person1 := TSmartPointer2<TPersons>.Create(TPersons.Create('Ali', 35));
  { The smart pointer has a reference count of 1. }

  Person1.Ref.Birthday;


  { Copy the smart pointer, it has a reference count of 2 now. }
  var Person2 := Person1;

  { Check properties }
  Assert(Person2.Ref.Age = 35);
  Assert(Person2.Ref.Name = 'Ali');

  { Person2 will go out of scope here, so only Person1
    will keep a reference to the TPerson object.
    The reference count will be reduced to 1. }


  { Check properties again }
  Assert(Person1.Ref.Age = 35);

  { Now Foo1 will go out of scope, reducing the
    reference count to 0 and destroying the TFoo object. }
{$ELSE}
  ShowMessage('This method works with Delphi 10.4 Sydney and above!');
{$ENDIF}
end;

procedure TForm1.Btn_SmartPointer3Click(Sender: TObject);
begin
 {$IF CompilerVersion >= 34.0}
  var Person1 := TSmartPointer3<TPerson>.Create(TPerson.Create('Ali', 35));
  { The smart pointer has a reference count of 1. }

  Person1.Ref.Birthday;

  { Copy the smart pointer, it has a reference count of 2 now. }
  var Person2 := Person1;
//
  { Check properties }
  Assert(Person2.Ref.Age = 35);
  Assert(Person2.Ref.Name = 'Ali');

  { Person2 will go out of scope here, so only Person1
    will keep a reference to the TPerson object.
    The reference count will be reduced to 1. }


  { Check properties again }
  Assert(Person1.Ref.Age = 35);

  { Now Foo1 will go out of scope, reducing the
    reference count to 0 and destroying the TFoo object. }
{$ELSE}
  ShowMessage('This method works with Delphi 10.4 Sydney and above!');
{$ENDIF}
end;

procedure TForm1.Btn_SmartPointer4Click(Sender: TObject);
begin
{$IF CompilerVersion >= 34.0}
  var Person1 := TSmartPointer4<TPerson>.Create(TPerson.Create('Ali', 35));
  { The smart pointer has a reference count of 1. }

  Person1.Ref.Birthday;

  { Copy the smart pointer, it has a reference count of 2 now. }
  var Person2 := Person1;

  { Check properties }
  Assert(Person2.Ref.Age = 35);
  Assert(Person2.Ref.Name = 'Ali');

  { Person2 will go out of scope here, so only Person1
    will keep a reference to the TPerson object.
    The reference count will be reduced to 1. }


  { Check properties again }
  Assert(Person1.Ref.Age = 35);

  { Now Foo1 will go out of scope, reducing the
    reference count to 0 and destroying the TFoo object. }
{$ELSE}
  ShowMessage('This method works with Delphi 10.4 Sydney and above!');
{$ENDIF}
end;

procedure TForm1.Btn_SmartPoniter5Click(Sender: TObject);
var
  LvPerson1: ISmartPointer5<TPerson>;
  LvPerson2: ISmartPointer5<TPerson>;
  LvPerson3: ISmartPointer5<TPerson>;
  PersonObj: TPerson;
begin
  // Typical usage when creating a new object to manage
  LvPerson1 := TSmartPointer5<TPerson>.Create(TPerson.Create('Person1', 45));
  LvPerson1.Birthday; // Direct member access!
  ShowName(LvPerson1); // Pass as smart pointer
  ShowAge(LvPerson1); // Pass as the managed object!
  //Person1 := nil; // Release early

  // Same as above but hand over to smart pointer later
  PersonObj := TPerson.Create('Person2', 90);
  // Later
  LvPerson2 := TSmartPointer5<TPerson>.Create(PersonObj);
  ShowName(LvPerson2);
  // Note: PersonObj is freed by the smart pointer

  // Smart pointer constructs the TPerson instance
  LvPerson3 := LvPerson2; // or Create(nil)
  LvPerson3.Name := 'Person3';
  LvPerson3.Birthday;
  // The smart pointer references are released in reverse declaration order
  // (Person3, Person2, Person1)
end;

procedure TForm1.Btn_SmartPoniter6Click(Sender: TObject);
var
  LvPerson1, LvPerson2: TPerson;
begin
  ShowMessage('Creating object Ali');
  LvPerson1 := SmartPointer6<TPerson>(TPerson.Create('Ali', 25));

  ShowMessage('Creating object Alex');
  LvPerson2 := SmartPointer6<TPerson>(TPerson.Create('Alex', 35));

  LvPerson1.Birthday;
  LvPerson2.Birthday;

  ShowMessage('OK, so they talked about their birthdates!');
  ShowMessage('End of the scope');
end;

procedure TForm1.Btn_SmartPoniter7Click(Sender: TObject);
var
  x: TSmartPointer7<TLifetimeWatcher>;
begin
  x := TLifetimeWatcher.Create(procedure
  begin
    ShowMessage('Destroying...');
  end);
  ShowMessage(X.Value.Birthday);
end;

procedure TForm1.Btn_ClassicClick(Sender: TObject);
var
  Lvperson: TPerson;
begin
  Lvperson := TPerson.Create('Frank', 20);
  // You'll get memory leak error on application terminate time, if you do not free LvPerson.
end;

{$REGION 'TPerson implementation'}
procedure TPerson.Birthday;
begin
  ShowMessage(FName + ' was born in year ' + IntToStr(CurrentYear - FAge));
end;

constructor TPerson.Create(const AName: string; const AAge: Integer);
begin
  FName := AName;
  FAge := AAge;
end;

constructor TPerson.Create;
begin
  FName := '';
  FAge := 0;
end;

destructor TPerson.Destroy;
begin
  ShowMessage('Destroying ' + FName + '...');
end;
{$ENDREGION}

{$REGION 'TPersons implementation'}
{$IF CompilerVersion >= 34.0}
procedure TPersons.Birthday;
begin
  ShowMessage(FName + ' was born in year ' + IntToStr(CurrentYear - FAge));
end;

constructor TPersons.Create(const AName: string; const AAge: Integer);
begin
  FName := AName;
  FAge := AAge;
end;

destructor TPersons.Destroy;
begin
  ShowMessage('Destroying ' + FName + '...');
  inherited;
end;
{$ENDIF}
{$ENDREGION}

end.
