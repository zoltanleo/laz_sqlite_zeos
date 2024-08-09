unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes
  , SysUtils
  , DB
  , DateUtils
  , Forms
  , Controls
  , Graphics
  , Dialogs
  , DBGrids, LazUtils, LazFileUtils
  , ZDataset
  , ZConnection
  , ZAbstractRODataset
  , ZDatasetUtils
  , ZDbcIntfs
  ;

type

  { TForm1 }

  TForm1 = class(TForm)
    ds: TDataSource;
    grTemp: TDBGrid;
    tmpConn: TZConnection;
    tmpQry: TZQuery;
    tmpTrans: TZTransaction;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FAppDir: String;
  public
    property AppDir: String read FAppDir;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

const
  SQLText =
    'SELECT ' +
        'P.ID' +
        ',P.LASTNAME' +
        ', P.FIRSTNAME' +
        ', P.THIRDNAME' +
        ', P.DATEBORN' +
        //', iif(P.SEX = 1,''male'',''female'') AS SEX ' +
        ', CASE ' +
            'WHEN P.SEX = 1 THEN ''male'' ELSE ''female'' ' +
          'END AS SEX ' +
    'FROM PERSONALITY P';

    SQLText_cnt =
    'SELECT count(P.ID) AS CNT ' +
    'FROM PERSONALITY P';



  {$IFDEF MSWINDOWS}
    DBFileName = 'base\test_base.db';
    LibFileName = 'sqlite_lib\sqlite3_x64.dll';
  {$ELSE}
    {$IFNDEF DARWIN}
    DBFileName = 'base/test_base.db';
    LibFileName = 'sqlite_lib/sqlite3.so';
    {$ELSE}
      LibFileName = '';
    {$ENDIF}

  {$ENDIF}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  FAppDir:= CleanAndExpandDirectory(ExtractFilePath(Application.ExeName));

  with tmpConn do
  begin
    ControlsCodePage:= cCP_UTF8;//uses ZDatasetUtils
    Database:= AppDir + DBFilename;
    LibraryLocation:= AppDir + LibFileName;
    Protocol:= 'sqlite';
    RaiseWarningMessages:= True;
    RawCharacterTransliterateOptions.Encoding:= encUTF8;//uses ZDbcIntfs
    TransactIsolationLevel:= tiReadCommitted;//uses ZDbcIntfs

    //Properties.Strings
    //BindDoubleDateTimeValues=False
    //codepage=characterset=utf8:65001/4
    //controls_cp=CP_UTF8
    //DateReadFormat=YYYY-MM-DD
    //DatetimeReadFormat=YYYY-MM-DD HH:NN:SS.F
    //DatetimeWriteFormat=YYYY-MM-DD HH:NN:SS.F
    //DateWriteFormat=YYYY-MM-DD
    //RawStringEncoding=CP_UTF8

  end;
end;

procedure TForm1.FormShow(Sender: TObject);
var
  tc, tc_cnt: QWord;
begin
  tmpConn.Connected:= True;
  try
    tc:= GetTickCount64;
    tmpQry.DisableControls;
    try
      tmpTrans.StartTransaction;

      tmpQry.Active:= False;
      tmpQry.SQL.Text:= SQLText_cnt;
      tmpQry.Active:= True;
      tc_cnt:= GetTickCount64 - tc;
      tc:= GetTickCount64;

      tmpQry.Active:= False;
      tmpQry.SQL.Text:= SQLText;
      tmpQry.Active:= True;
      tmpQry.First;

      tmpTrans.Commit;
    except
      on E:EZDatabaseError do
      begin
        tmpTrans.Rollback;
        ShowMessage(E.Message);
      end;
    end;
  finally
    tmpQry.EnableControls;
    Self.Caption:= Format('Time fetching for - record count: %d ms/- 100K records %d ms', [tc_cnt, GetTickCount64 - tc]);
  end;
end;

end.

