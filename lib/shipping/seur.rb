module Shipping
  class SEUR < Base
    def label
      # @required = [:seur_user, :seur_password, :nif, :seur_franquicia, :seur_ccc, :seur_integracion, :cod_socio]
      packetsXML = String.new
      sendXML = String.new
      xmlBuilder = Builder::XmlMarkup.new :target => sendXML
      xmlPacketsBuilder = Builder::XmlMarkup.new :target => packetsXML

      # xmlPacketsBuilder.instruct! :xml, :version=>"1.0", :encoding=>"ISO-8859-1"
      xmlPacketsBuilder.root { |b|
        xmlPacketsBuilder.exp do
          @packages.each do |packet|
            xmlPacketsBuilder.bulto do
              xmlPacketsBuilder.ci @seur_integracion
              xmlPacketsBuilder.nif @nif
              xmlPacketsBuilder.ccc @seur_ccc
              xmlPacketsBuilder.servicio packet[:servicio]
              xmlPacketsBuilder.producto packet[:producto]
              xmlPacketsBuilder.total_bultos packet[:total_bultos]
              xmlPacketsBuilder.total_kilos packet[:total_kilos]
              xmlPacketsBuilder.observaciones nil#packet[:observaciones]
              xmlPacketsBuilder.referencia_expedicion packet[:referencia_expedicion]
              xmlPacketsBuilder.ref_bulto packet[:ref_bulto]
              xmlPacketsBuilder.clavePortes packet[:clavePortes]
              xmlPacketsBuilder.claveReembolso nil
              xmlPacketsBuilder.valorReembolso nil
              xmlPacketsBuilder.nombre_consignatario @company
              xmlPacketsBuilder.direccion_consignatario @address
              xmlPacketsBuilder.tipoVia_consignatario packet[:tipoVia_consignatario]
              xmlPacketsBuilder.tNumVia_consignatario packet[:tNumVia_consignatario]
              xmlPacketsBuilder.numVia_consignatario packet[:numVia_consignatario]
              xmlPacketsBuilder.escalera_consignatario packet[:escalera_consignatario]
              xmlPacketsBuilder.piso_consignatario packet[:piso_consignatario]
              xmlPacketsBuilder.puerta_consignatario packet[:puerta_consignatario]
              xmlPacketsBuilder.poblacion_consignatario @city
              xmlPacketsBuilder.codPostal_consignatario @zip
              xmlPacketsBuilder.pais_consignatario @country
              xmlPacketsBuilder.telefono_consignatario @phone
              xmlPacketsBuilder.atencion_de nil
              xmlPacketsBuilder.test_preaviso packet[:test_preaviso]
              xmlPacketsBuilder.test_reparto packet[:test_reparto]
              xmlPacketsBuilder.test_email packet[:test_email]
              xmlPacketsBuilder.email_consignatario @email
            end
          end
        end
      }
      xmlPacketsBuilder.target!


      xmlBuilder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      xmlBuilder.tag!("soapenv:Envelope", "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/", 'xmlns:imp' => 'http://localhost:7026/ImprimirECBWebService') do
        xmlBuilder.tag!('soapenv:Header')
        xmlBuilder.tag!('soapenv:Body') do
          xmlBuilder.tag!('imp:impresionIntegracionPDFConECBWS') do
            xmlBuilder.imp :in0, @seur_user
            xmlBuilder.imp :in1, @seur_password
            xmlBuilder.imp :in2 do
              xmlBuilder.cdata!("#{packetsXML}")
            end
            xmlBuilder.imp :in3, 'JUGUETTOS.XML'
            xmlBuilder.imp :in4, @nif
            xmlBuilder.imp :in5, @seur_franquicia
            xmlBuilder.imp :in6, -1
            xmlBuilder.imp :in7, 'JuguettosTHECOCKTAIL'
          end
        end
        xmlBuilder.target!
      end
      
      @data = sendXML
      # @logger.debug("SEUR Track:#{@data}")
      get_seur_response('http://cit.seur.com/CIT-war/services/ImprimirECBWebService?wsdl', 'impresion_integracion_pdf_con_ecbws', 'imp')
    end
    
    def checkExpeditions
      @data = {
        :in0 => @expeditionType,
        :in1 => @expeditionID,
        :in2 => @trackingID,
        :in3 => @referenceID,
        :in4 => @ccc,             #Por defecto busca en todos los CCC's del cliente si no se pone nada. El formato de la cadena es ‘<CCC1>’,’<CCC2>’,...
        :in5 => @fromDate,        #formato dd-mm-yyyy
        :in6 => @toDate,          #formato dd-mm-yyyy
        :in7 =>@situation,        #Si es vacio devuelve todas las situaciones TODO Obtener las situaciones del Sistema Maestro de Seur
        :in8 => @name,            #Origen o Destino segun @expeditionType
        :in9 => @city,            #Origen o Destino segun @expeditionType
        :in10 => @ecb,
        :in11 => @changeService,  # 1 = seleccionado, 0 = no seleccionado
        :in12 => @seur_user,
        :in13 => @seur_password,
        :in14 => @requestType     #S = pública N = privada
      }
      get_seur_response("https://ws.seur.com/webseur/services/WSConsultaExpediciones?wsdl", 'consulta_listado_expediciones_str', 'con')
    end
  end
end