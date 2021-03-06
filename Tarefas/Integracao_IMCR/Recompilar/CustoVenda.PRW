#Include "Rwmake.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �IdadeAtu  �Autor  �M�rcio Quevedo Borges Data �  27/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Fun��o de C�lculo da Data da Idade e Idade atualizada    -���
���          �  baseada na database atual                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function IdadeAtu(nQant,nIdade,dDtIdade)

	Local nIdadeAtu := 0
/*
PAR�METROS
-------------
nQant 	 -> Quantidade AP�S A MOVIMENTACAO ATUAL do item na data do item, usado pra saber se o estoque ser� zerado
dDtIdade -> Data da Idade do item
nIdade	 -> idade do item na data da idade

*/

	If nIdade == Nil .OR. dDtIdade == Nil .OR. nQant == Nil
		Return nIdadeAtu
	Endif

	If !Empty(dDtIdade) .AND. nQant <> 0

		dDtIdadeAtu := MAX(dDatabase , dDtIdade)
		ndtdif		:= ABS(dDatabase - dDtIdade)  //VALOR ABSOLUTO  ? ABS(dDtIdadeAtu - dDtIdade)
		nIdadeAtu 	:= (ndtdif) + nIdade   //idade anterior atualizada com o tempo at� a database

	Else
		nIdadeAtu	:= 0
	Endif



Return nIdadeAtu

//---------------------------------------------------------------------------------------------------------------


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �CalcFatores�Autor  �M�rcio Quevedo Borges Data �  02/17/06   ���
��������������������������������������������������������������������������͹��
���Desc.     �  Fun��o de C�lculo da Idade dos produtos, baseado na entra- ���
���          �  da de dados da movimenta��o atual                          ���
��������������������������������������������������������������������������͹��
���PAR�METROS�															   ���
��������������������������������������������������������������������������͹��
���cProduto  � Produto na qual se quer calcular a idade					   ���
���cLocal	 � Estoque que se vai efetuar o processo					   ���
���nQnovo	 � Quantidade que est� sendo movimentada no estoque		       ���
���nIdade    � idade do produto que est� sendo movimentado                 ���
���nCOEFC    � Coeficiente cambial do produto que est� sendo movimentado   ���
���nCOEFF    � Coeficiente Financ. do produto que est� sendo movimentado   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

User Function CalcFatores(cProduto,cLocal,nQtd,nCOEFC,nCOEFF,nIdade,NTIPO,CBME,NQANTB2,NIDADE2ANT) //ACRESCER CTIPO,CFORNEC
	Local cProduto,cLocal,nQtd,nCOEFC,nCOEFF,nIdade
	Local nCOEFCAnt := 0 ,nCOEFFAnt  := 0 , nIdadeAnt :=0
	Local nCOEFCAtu := 0 ,nCOEFFAatu := 0 , nIdadeAtu :=0 , dDtIdadeAtu := dDatabase
	Local dDataIdade := CTOD("  /  /  "), cQant:=0, nQnovo := 0
	Local cAlias:= Alias()
	Local nIndex:= IndexOrd()
	Local nRec  := Recno()
	Local cRecSB2 := SB2->( Recno() )
	Local nQant	  := 0

//JULIO JACOVENKO, em 24/01/2012
//Projeto Idade Imdepa
	If NTIPO == Nil
		NTIPO:='IF'
	Endif
	If CBME == Nil
		CBME:=''
	Endif

	If cProduto == Nil
		Return Nil
	Endif
	If cLocal == Nil
		cLocal := '01'
	Endif
	If nQtd == Nil
		nQtd := 0
	Endif
	If nIdade == Nil
		nIdade := 0
	Endif

	//If NQANTB2 == Nil
	   //NQANTB2:=1
	//Endif

    If NIDADE2ANT == Nil
       NIDADE2ANT:=1
    Endif

	dbSelectArea('SB2')
	dbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

//Localiza Tempo de Vida do Produto
	IF SB2->( MsSeek( xFilial('SB2')+cProduto+cLocal,.F. ))  //busco sempre do armaz�m 01

	//	dDataIdade 	:= SB2->B2_DTIDADE
	   IF NQANTB2<>NIL
		nQant		:= NQANTB2 //SB2->B2_QATU
	   ELSE
	    nQant		:= SB2->B2_QATU
	   ENDIF

       //ALERT('NQANT ----> '+STR(SB2->B2_QATU)+'   '+STR(NQANT)+' PROD '+SB2->B2_COD+'  '+SB2->B2_FILIAL+'  '+SB2->B2_LOCAL)

		nIdadeAnt	:= u_IdadeAtu(nQant,SB2->B2_IDADE,SB2->B2_DTIDADE)

        ///QUESTAO DA BME
		n2IdadeAnt	:= u_IdadeAtu(nQant,SB2->B2_IDIMDE,SB2->B2_DTCALC)


		nCOEFCAnt	:= SB2->B2_COEFC
		nCOEFFAnt	:= SB2->B2_COEFF

		IF CBME==''        //MOVIMENTOS NORMAIS
		                   //ENTRADA, SAIDA, DEVOLUCAO

			IF SF1->F1_TIPO<>'D' .AND. SF1->F1_FORNECE<>'N00000'
               ///ajustado final em 27/03/2012
				NIDADEIMD:=1
				NIDADEY:=DATE()
				IF SB2->B2_IDIMDE=0
					NIDADEIMD:=SB2->B2_IDADE
					NIDADEY  :=SB2->B2_DTIDADE
				ELSEIF SB2->B2_IDIMDE<>0
					NIDADEIMD:=SB2->B2_IDIMDE
					NIDADEY:=SB2->B2_DTCALC
				ENDIF
				NQANTX:=NQANT
				IF NQANT<=0
					NQANTX:=0
				ENDIF

				nIdade2	:= u_IdadeAtu(nQantX,NIDADEIMD,NIDADEY)
                ///////////////////////////////////
			   //nIdade2	:= u_IdadeAtu(nQant,SB2->B2_IDADE,DATE())
			ELSE
			    //ALERT("..TRANFERENCIA CUSTOVENDA...")


				NIDADEIMD:=1
				NIDADEY:=DATE()
				IF SB2->B2_IDIMDE=0
					NIDADEIMD:=SB2->B2_IDADE
					NIDADEY  :=SB2->B2_DTIDADE
				ELSEIF SB2->B2_IDIMDE<>0
					NIDADEIMD:=SB2->B2_IDIMDE
					NIDADEY:=SB2->B2_DTCALC
				ENDIF

				nIdade2	:= u_IdadeAtu(nQant,NIDADEIMD,NIDADEY)
			ENDIF
			///
			///JULIO JACOVENKO, 09/01/2012
			///SE FOR DEVOLUCAO NAO CONSIDERA
			///////////////////////////////////////////////////////
			IF SF1->F1_TIPO='D'
				NIDADEIMD:=1
				NIDADEY:=DATE()
				IF NQANT<=0
					NQANT:=0
				ENDIF
				nIdade2	:= u_IdadeAtu(nQant,NIDADEIMD,NIDADEY)
			ENDIF
			////
			////////////////////////////////////////////////////////

		ELSEIF CBME=='BME' .OR. CBME='BME2' .OR. CBME=='MOV'  //movimentes BME ou transf. mod. II
			NIDADEIMD:=1
			NIDADEY:=DATE()

			IF SB2->B2_IDIMDE=0
				NIDADEIMD:=SB2->B2_IDADE
				NIDADEY  :=SB2->B2_DTIDADE
			ELSEIF SB2->B2_IDIMDE<>0
				NIDADEIMD:=SB2->B2_IDIMDE
				NIDADEY:=SB2->B2_DTCALC
			ENDIF

			IF NQANT<0
				NQANT:=0
			ENDIF

			nIdade2	:= 1 //u_IdadeAtu(nQant,NIDADEIMD,NIDADEY)

			IF NQANT<=0 .AND. SB2->B2_IDADE>0 .AND. SB2->B2_IDIMDE<=0
				nIDADE2:=1
			ELSEIF NQANT<=0 .AND. SB2->B2_IDADE=0 .AND. SB2->B2_IDIMDE=0
				nIDADE2:=1
			ELSEIF NQANT>0  .AND. SB2->B2_IDADE>0 .AND. SB2->B2_IDIMDE=0
				nIDADE2:=1
			ENDIF


		ENDIF

    //////////////////////////////////////////////////////////

	ENDIF

//////JULIO JACOVENKO, em 24/01/2012
//////Projeto Idade Imdepa



	IF NTIPO='IF'
		nCOEFCAtu	:= (nQant * nCOEFCAnt + nQtd * nCOEFC) / (nQant + nQtd)
		nCOEFFAtu   := (nQant * nCOEFFAnt + nQtd * nCOEFF) / (nQant + nQtd)
		nIdadeAtu	:= (nQant * nIdadeAnt + nQtd * nIdade) / (nQant + nQtd)
       ///JULIO JACOVENKO, em 15/05/2012
		IF CBME=='BME'

			nIdadeAtu	:= (nQant * nIdadeAnt + nQtd * 1) / (nQant + nQtd)

			//ALERT('NidadeAant '+str(nIdadeAnt))
			//ALERT('NQANT '+STR(NQANT))
			//ALERT('NQTD  '+STR(NQTD))


        ELSEIF CBME=='BME2'
			nIdadeAtu	:= (nQant * n2IdadeAnt + nQtd * 1) / (nQant + nQtd)

			//ALERT('N2IdadeAnt '+str(n2idadeAnt))
			//ALERT('NQANT '+STR(NQANT))
			//ALERT('NQTD  '+STR(NQTD))


	    ELSEIF CBME=='TRAN'
	        //ALERT(SB2->B2_COD)
	        //ALERT(nQant)
	        //ALERT(NIDADE)
	        //ALERT(nQTD)
	        //ALERT(NQANT+NQTD)
           //ALERT(' --->IDADE 1 TRAN <------ '+STR(NIDADE2ANT))
           //ALERT('NQANT '+STR(nQant)+' NIDADE '+STR(NIDADE)+' NQTD '+STR(NQTD)+' NIDADE2ANT '+str(nidade2ant)+' / ('+STR(nQant + nQtd)+') ')
	        nIdadeAtu	:= (nQant * NIDADE + nQtd * NIDADE2ANT) / (nQant + nQtd)
	    ELSEIF CBME=='TRANO'
	       //ALERT(' --->IDADE 2 TRANO <------ '+STR(NIDADE2ANT))
           //ALERT('NQANT '+STR(nQant)+' NIDADE '+STR(NIDADE)+' NQTD '+STR(NQTD)+' NIDADE2ANT '+str(nidade2ant)+' / ('+STR(nQant + nQtd)+') ')
	        nIdadeAtu	:= (nQant * NIDADE + nQtd * NIDADE2ANT) / (nQant + nQtd)
	        //ALERT('--->IDADE TRANO NQANT '+STR(nQant)+' NIDADE '+STR(NIDADE)+' NQTD '+STR(NQTD)+' NIDADE2ANT '+str(nidade2ant)+' / ('+STR(nQant + nQtd)+') ')
		ENDIF

	ELSE
		nCOEFCAtu	:= (nQant * nCOEFCAnt + nQtd * nCOEFC) / (nQant + nQtd)
		nCOEFFAtu   := (nQant * nCOEFFAnt + nQtd * nCOEFF) / (nQant + nQtd)

        //QTD ATU * IDADE ATUAL  //QTD ENT + NOVA IDADE

		IF CBME=='BME' .OR. CBME='BME2' .OR. CBME=='MOV' //modalidade para BME
			nIdadeAtu	:= (nQant * nIDADE  + nQtd * nIdade2) / (nQant + nQtd)
		ELSE //modalidade para nota entrada e transferencia
			nIdadeAtu	:= (nQant * nIdade2 + nQtd * nIdade) / (nQant + nQtd)
		//nIdadeAtu	:= (nQant * nIDADE + nQtd * nIdade2) / (nQant + nQtd)
		ENDIF

	ENDIF

//Se a Quantidade em estoque for zerada, zera a vida tamb�m
//nIdadeAtu 	:= IIF(nQant + nQtd == 0 , 0 , nIdadeAtu)
//��������������������Ŀ
//�Restaura o ambiente.�
//����������������������

	SB2->( DbGoTo(cRecSB2) )
	DbSelectArea(cAlias)
	DbSetorder(nIndex)
	DbGoTo(nRec)

	aFatores := {nCOEFCAtu,nCOEFFAtu,nIdadeAtu,dDtIdadeAtu}

Return aFatores


//---------------------------------------------------------------------------------------------------------------

/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Programa  �IMDG005      � Autor �Marcio Quevedo Borges  � Data �24/02/2006���
���Gatilho   �IMDG005      �       �                       �      �          ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Busca Idade do Item na digita��o da Nf de Entrada             ���
����������������������������������������������������������������������������Ĵ��
��� 24/02/06 � MQB     �Gatilho acionado na digitacao do C�digo              ���
��� 29/03/06 � MQB     �Acionado na Confirmacao da NF                        ���
���          �         �                                                     ���
���          �         �                                                     ���
���          �         �                                                     ���
����������������������������������������������������������������������������Ĵ��
���Uso		 �ESPECIFICO PARA O CLIENTE IMDEPA       					     ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
User Function IMDG005(nI)

// var publica dtEmissao,CLoja , cNFiscal , cSerieOri , CA100For

	Local lFaltaCampo := .F.
	Local aAreaAtu  := GetArea()
	Local aAreaSB1  := SB1->( GetArea() )
	Local aAreaSF1  := SF1->( GetArea() )
	Local aAreaSD2  := SD2->( GetArea() )
	Local aAreaSF4  := SF4->( GetArea() )
	Local nCont
	Local nD1_COD, nD1_TES := 0, nD1_NFORI, nD1_SERIORI, nD1_ITEMORI,nD1_QUANT
	Local nD1_IDADE, nD1_COEFC,nD1_COEFF,nDELETE,cD1_NUMDI
//JULIO JACOVENKO, em 14/04/2012
//Na transferencia idade filial entra com HUM
	Local nIdade 	:= 1 //0
	Local nIdade1   := 0
	Local nCOEFC	:= 0
	Local nCOEFF	:= 0
	Local DtIdade 	:= dDEmissao
	Local cSerieOri
	Local cMens:=' '

	Local nLin := 1
	Local lTransf:=.F.

//MSGBOX("...ENTROU NA FUNCAO INDG006...","Ponto de Entrada","INFO")

/////JULIO JACOVENKO, EM 24/01/2012
/////Projeto Idade Imdepa
	nD1_DTCALC  :=Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_DTCALC'}) ///Data do Calculo Idade Imdepa
	nD1_IDIMDE  :=Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_IDIMDE'}) ///Calculo Idade Imdepa
//////////////////////////////////////////////////////////////////////////////

	nD1_COD    	:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_COD'})
	nD1_TES    	:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_TES'})
	nD1_NFORI   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_NFORI'})
	nD1_SERIORI := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_SERIORI'})
	nD1_ITEMORI := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_ITEMORI'})
	nD1_QUANT	:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_QUANT'})
	nD1_IDADE   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_IDADE'})
	nD1_COEFC   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_COEFC'})
	nD1_COEFF   := Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_COEFF'})
	nDELETE   	:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'DELETE'})
	nD1_LOCAL 	:= Ascan(aHeader,{|x| Alltrim(x[2]) == 'D1_LOCAL'})

	nDELETE		:= IIF(nDelete == 0,len(aheader)+1,nDELETE)
	cD1_NUMDI	:= alltrim(gdFieldGet("D1_NUMDI",nI)) //BUSCA O DADO DE DETERMINADA LINHA DO ACOLS
	cD1_CONHEC	:= alltrim(gdFieldGet("D1_CONHEC",nI))

	cCFOFrete 	:= alltrim(GETMV("MV_CFOFRET"))
	lFrete		:= (alltrim(gdFieldGet("D1_CF",nI)) $ cCFOFrete)
	lTipo		:= cTipo $ 'N/D'
	cOperaWms := GetMv("MV_WMSTPAP",,"F")


	FOR nLin := 1 to  Len(aCols) // Agostinho - 11/11/2011 - O sistema nao valida se a tes esta bloqueada quando vem do pedido de compra.

		IF ! GDDeleted(nLin) .and. !Empty(Alltrim(aCols[ nLin, nD1_TES ]))
			IF POSICIONE("SF4",1,XFILIAL("SF4")+aCols[ nLin, nD1_TES ],"F4_MSBLQL") = "1"
				Aviso("TES BLOQUEADA","A TES "+aCols[ nLin, nD1_TES ]+" esta bloqueada! Contate o setor fiscal e corrija a TES!", {"Ok"})
				lRet := .F.
				RETURN(lRet)
			ENDIF
		ENDIF

//NEXT

//Inserido por Edivaldo Gon�alves Cordeiro em 25/04/2007
//Configura��o Autom�tica para produtos que est�o sem o controle de localiza��o - WMS

		cMens := OemToAnsi('Caro Usu�rio :'+ALLTRIM(SUBSTR(cusuario,7,15)))+chr(13)+chr(13)
		cMens := cMens+OemToAnsi('o Produto '+Alltrim(SB1->B1_COD)+'/'+Alltrim(SB1->B1_DESC)+chr(13))
		cMens := cMens+OemToAnsi('N�o possuia Controle de Localiza��o !,o sistema configurou Automaticamente.')

		IF  !(aCols[ nLIN, nDELETE ]) .AND. cOperaWms<>'F'

			// Jean Rehermann - SOLUTIO IT - 12/01/2016 - Corre��o no teste l�gico abaixo.
			//If  SB1->B1_LOCALIZ <> 'S' .AND. SB1->B1_TIPO='PA' .OR. SB1->B1_TIPO='PP' .OR. SB1->B1_TIPO='MP'
			If  SB1->B1_LOCALIZ <> 'S' .AND. SB1->B1_TIPO $ 'PA/PP/MP'

				lLock := RecLock("SB1",.F.)
				SB1->B1_LOCALIZ :='S'

				If lLock
					MsUnlock()
				Endif

		//SB1->B1_TIPO $ UPPER(GETMV("MV_TIPO",," "))
		//aa/aa/aa/aa/aa

				MsgBox(cMens,"WMS Configura��o Autom�tica !","INFO")
			Endif

		Endif


		IF  !(aCols[ nLIN, nDELETE ])  .AND. !lFrete .AND. lTipo // SE O REGISTRO N�O ESTIVER DELETADO e for devolucao ou normal


			IF nI <> Nil .and. nI <> n
				n := nI
			ENDIF

			IF nD1_IDADE == 0
				lFaltaCampo := .T.
			ENDIF
			IF nD1_COEFC == 0
				lFaltaCampo := .T.
			ENDIF
			IF nD1_COEFF == 0
				lFaltaCampo := .T.
			ENDIF
			IF 	lFaltaCampo
				ALERT("Para o funcionamento correto do c�lculo da margem, verifique a exist�ncia destes campos 'D1_IDADE, D1_COEFC e D1_COEFF")
				lRet := .F.
				Return( lRet )
			ENDIF

			SW6->( dbSetOrder( 1 ) ) //DI (IMPORTACAO)
			SB1->( dbSetOrder( 1 ) )
			SF4->( dbSetOrder( 1 ) )
			SD2->( dbSetOrder( 3 ) )	// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM


			If cTipo <> 'D' // SE N�O � DEVOLU��O
				IF CA100For == 'N00000' // Se a NFE for de transfer�ncia     + CLoja

					cSerieOri := "I"+CLoja			// Armazena a s�rie da NF de Origem
					lTransf:=.T.

					SD2->( dbSeek( CLoja + cNFiscal + cSerieOri + CA100For + cFilAnt + aCols[ nLin, nD1_COD ] , .F. ) )

					nIdade  := SD2->D2_IDADE
					nIdade1 := SD2->D2_IDIMDE
					DtIdade := SD2->D2_EMISSAO
					nCOEFC  := SD2->D2_COEFC
					nCOEFF	 := SD2->D2_COEFF

				ELSE // Se � entrada de MP de Fornecedor

		    ////Idade j� existente, chamaremos de idade filial
					nIdade 	:= 1
					DtIdade := dDEmissao

		    ////JULIO JACOVENKO, em 24/01/2012
		    ////Projeto Idade
		    ////IDADE INICIAL NA ENTRADA/transf VIA NF
		    //////////////////////////////////
					nIdade1 := 1         //sempre ser� HUM via NF
					DtIdade1:= dDEmissao //data da digita��o da NF
   			//// Busca PELA CHAVE 1 - B2_FILIAL+B2_COD+B2_LOCAL
//			IF SB2->( dbSeek( Cloja+aCols[ nLIN, nD1_COD ]+'01',.F.))
					IF SB2->( dbSeek( Cloja+aCols[ nLIN, nD1_COD ]+aCols[ nLIN, nD1_LOCAL ],.F.))

			   ///JULIO JACOVENKO, 02/03/2012
			   //////////////////////////////
						NIDADEX:=1
						NIDADEY:=DATE()

						nIdade1   := NIDADEX   //iif(SB2->B2_IDIMDE<>0,SB2->B2_IDIMDE,NIDADEX)
						DtIdade   := dDEmissao
					ENDIF
		    //////////////////////////////////////////////////////////////

			//����������������������Ŀ
			//� Trata os Coeficientes�
			//������������������������

			// Se o item � de Importado/Nacionalizado
					IF SB1->B1_ORIGEM $ "1/2"
						IF	EMPTY(cD1_NUMDI) .AND. !EMPTY(cD1_CONHEC) // Se NAO for digitado a D.I.
							ALERT("Produto " + alltrim(gdFieldGet("D1_COD",nI)) + " � importado/nacionalizado ! Didite uma DI para este item !")
					//lRet := .F.
						ELSE
							IF SW6->( dbseek(xFilial("SW6")+ cD1_NUMDI ))
								nCOEFC  := SW6->W6_COEFC
								nCOEFF	:= SW6->W6_COEFF
							ENDIF
						ENDIF
					ELSE
						IF !EMPTY(cD1_NUMDI)
							ALERT("Numero de DI � usado em Produto Importado. o Produto " + alltrim(gdFieldGet("D1_COD",nI)) + " n�o  importado/nacionalizado no campo B1_ORIGEM ! Verifique o Cadastro de Produto !!!")
					//lRet := .F.
						ELSE
					// Calcula Coeficiente Financeiro trazido ao momento presente, e Cambial = 0
							IF MaFisRet(,"NF_BASEDUP") > 0 .And. Empty(cCondicao)
						//���������������������������������������������Ŀ
						//� Verifica a condicao de pagamento.           �
						//�����������������������������������������������

								HELP("  ",1,"A100COND")
								If ( Type("l103Auto") == "U" .OR. !l103Auto )
									oFolder:nOption := 6   // Coloca foco no folder de condi��o de pagamento (Iuspa)
								EndIf

								ALERT("Favor preencher a Condi��o de Pagamento !")
								nCOEFF	:=	0
								lRet 	:= .F.
							ELSE
								nTxFin  				:= GETMV("MV_TXFIN",,0)/100  // Similar a Taxa CDI , mas ao m�s
								nPrazoMedioCobr 		:= Posicione("SE4",1,xFilial("SE4")+cCondicao,"E4_PRZMED")
								nTaxaDiaria 			:=  (1 + nTxFin )^(1/30) -1
								nIndiceDeflacionado 	:= (1 / ((1 + nTaxaDiaria) ^ nPrazoMedioCobr )) -1
								nCOEFF					:= nIndiceDeflacionado
							ENDIF

							nCOEFC  := 0
						ENDIF
					ENDIF
				ENDIF

		// nPCofins := If( dDataBase <= dDtCof, nTxCofi1, nPCofins )
			Else           // SE � DEVOLU��O
		// pesquisa a nota fiscal de venda original...
				SD2->( dbSeek( xFilial( 'SD2' ) + aCols[ nLIN, nD1_NFORI ] + aCols[ nLIN, nD1_SERIORI ] + CA100For + CLoja + aCols[ nLIN, nD1_COD ] + aCols[ nLIN, nD1_ITEMORI ], .F. ) )

				nIdade 	:= SD2->D2_IDADE
				DtIdade	:= SD2->D2_EMISSAO
				nCOEFC  := SD2->D2_COEFC
				nCOEFF	:= SD2->D2_COEFF

			EndIf

	///Idade Produto Filial

			IF CA100For <> 'N00000'
				nIdade1 := u_IdadeAtu(aCols[ nLIN, nD1_QUANT ],nIdade1,DtIdade)

			ENDIF
	////////////////////////////////////////////////////////////

	//////idade produto filiais
			aCols[ nLIN, nD1_IDADE ] := nIdade
			aCols[ nLIN, nD1_COEFC ] := nCOEFC
			aCols[ nLIN, nD1_COEFF ] := nCOEFF

	/////JULIO JACOVENKO, em 24/01/2012
	/////Projeto Idade Imdepa

	//ALERT('...IMDG005...COLOCANDO NO SD1...'+STR(NIDADE1))

			aCols[ nLIN, nD1_IDIMDE  ] := nIdade1
			aCols[ nLIN, nD1_DTCALC  ] := dDEmissao
    /////////////////////////////////////////////

		ENDIF

	NEXT

//MsgInfo("Executou Gatilho IMDG005 - Idade NF entrada = ")

	RestArea( aAreaSF4 )
	RestArea( aAreaSD2 )
	RestArea( aAreaSB1 )
	RestArea( aAreaAtu )

Return ( lRet )

//---------------------------------------------------------------------------------------------------------------


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FBuscaIdade�Autor  �JULO JACOVENKO     � Data �  04/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
USER FUNCTION FBuscaIdade(cCod,cLoc)
	Local nIdade:=0
	Local _cArea:=GetArea()

	DbSelectArea('SB2')
	DbSetOrder(1)

	If DBSeek(xFilial()+cCod+cLoc)
		nIdade:=SB2->B2_IDIMDE
	Endif

	RestArea(_cArea)
Return nIdade

