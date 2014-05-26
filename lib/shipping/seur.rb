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
              xmlPacketsBuilder.pesoBulto packet[:total_kilos]
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
      get_seur_response('http://cit.seur.com/CIT-war/services/ImprimirECBWebService?wsdl', 'impresion_integracion_pdf_con_ecbws', 'imp')
    end

    def track referencia_expedicion
      sendXML = String.new
      xmlBuilder = Builder::XmlMarkup.new :target => sendXML
      xmlBuilder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      xmlBuilder.tag!("soapenv:Envelope", "xmlns:soapenv" => "http://schemas.xmlsoap.org/soap/envelope/", 'xmlns:con' => 'http://consultaExpediciones.servicios.webseur') do
        xmlBuilder.tag!('soapenv:Header')
        xmlBuilder.tag!('soapenv:Body') do
          xmlBuilder.tag!('con:consultaListadoExpedicionesStr') do
            xmlBuilder.con :in0, 'S'
            xmlBuilder.con :in1, nil
            xmlBuilder.con :in2, nil
            xmlBuilder.con :in3, referencia_expedicion
            xmlBuilder.con :in4, nil
            xmlBuilder.con :in5, nil
            xmlBuilder.con :in6, nil
            xmlBuilder.con :in7, nil
            xmlBuilder.con :in8, nil
            xmlBuilder.con :in9, nil
            xmlBuilder.con :in10, nil
            xmlBuilder.con :in11, nil
            xmlBuilder.con :in12, @seur_user
            xmlBuilder.con :in13, @seur_password
            xmlBuilder.con :in14, 'S'
          end
        end
      end
      xmlBuilder.target!
      @data = sendXML

      get_seur_response('https://ws.seur.com/webseur/services/WSConsultaExpediciones?wsdl', 'consulta_listado_expediciones_str', 'con')
    end
  end
end
