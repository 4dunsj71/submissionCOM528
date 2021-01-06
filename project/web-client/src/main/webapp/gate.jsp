<%@page import="java.util.UUID"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.util.List"%>
 <%@page import="java.util.Calendar"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.Date"%>
<%@page import="org.solent.com528.project.impl.webclient.WebClientObjectFactory"%>
<%@page import="org.solent.com528.project.model.service.ServiceFacade"%>
<%@page import="org.solent.com528.project.model.dao.StationDAO"%>
<%@page import="org.solent.com528.project.model.dto.Station"%>
<%@page import="org.solent.com528.project.model.dao.TicketMachineDAO"%>
<%@page import="org.solent.com528.project.model.dto.TicketMachine"%>
<%@page import="org.solent.com528.project.model.dto.Ticket"%>
<%@page import="org.solent.com528.project.model.dao.PriceCalculatorDAO"%>
<%@page import="org.solent.com528.project.impl.service.rest.client.ConfigurationPoller"%>
<%@page import="org.solent.com528.project.model.dto.PricingDetails"%>
<%@page import="org.solent.com528.project.clientservice.impl.TicketEncoderImpl"%>
<%@page import ="java.io.StringReader"%>
<%@page import ="java.io.StringWriter"%>
<%@page import="javax.xml.bind.JAXBContext"%>
<%@page import="javax.xml.bind.JAXBException"%>
<%@page import="javax.xml.bind.Marshaller"%>
<%@page import="javax.xml.bind.Unmarshaller"%>
<%@page import="org.solent.com528.project.clientservice.impl.TicketEncoderImpl"%>
<%@page import="org.solent.com528.project.model.dto.Ticket"%>


<%
    // accessing service 
    ServiceFacade serviceFacade = (ServiceFacade) WebClientObjectFactory.getServiceFacade();
    StationDAO stationDAO = serviceFacade.getStationDAO();
    //TicketMachineDAO tmdao = serviceFacade.getTicketMachineDAO();
    Set<Integer> zones = stationDAO.getAllZones();
    List<Station> stationList = new ArrayList<Station>();
    PriceCalculatorDAO pcdao = serviceFacade.getPriceCalculatorDAO();
    ConfigurationPoller configurationPoller = new ConfigurationPoller(serviceFacade);
    
    
    //messages
    String errorMessage = "";
    String message = "";
    String message2 = "";
    String rateStr = "OffPeak";
    //accessing request parameters
    String encodedTicketStr1 = request.getParameter("encodedTicketStr");
    String desStationName = request.getParameter("desStationName");
    String desZoneStr = request.getParameter("desZoneStr");
    String depStationName = request.getParameter("depStationName");
    String depZoneStr = request.getParameter("depZoneStr");
    String depTimeStr = request.getParameter("depTimeStr");
    String arrTimeStr = request.getParameter("arrTimeStr");
    String zonesTravStr = request.getParameter("zonesTravStr");
    String validToStr = request.getParameter("validToStr");
    String costStr = request.getParameter("costStr");
    String actionStr = request.getParameter("action");
    Double cost = Double.parseDouble(costStr);
    String ticketStr = request.getParameter("ticketStr");

    
    Ticket t = new Ticket();
    
    //Integer depZone = Integer.parseInt(depZoneStr);
    //Integer desZone = Integer.parseInt(desZoneStr);
    //Integer zonesTrav = Integer.parseInt(zonesTravStr);
    
    //parsing Long from String
    Long depTimeLong = Long.parseLong(depTimeStr);
    Long arrTimeLong = Long.parseLong(arrTimeStr);
    Long validToLong = Long.parseLong(validToStr);
    
    
    //new calendar objects
    Calendar calDepTime = Calendar.getInstance();
    Calendar calArrTime = Calendar.getInstance();
    Calendar calValidTo = Calendar.getInstance();
    
    //setting time in M/s as Long
    calDepTime.setTimeInMillis(depTimeLong);
    calArrTime.setTimeInMillis(arrTimeLong);
    calValidTo.setTimeInMillis(validToLong);
    
    //instantiating date objects with calendar variables
    Date depTime = calDepTime.getTime();
    Date arrTime = calArrTime.getTime();
    Date validTo = calValidTo.getTime();
    
    t.setIssueDate(depTime);
    t.setStartStation(depStationName);
    t.setCost(cost);
    //create encoded string of ticket from get variables
    String encodedTicketStr = TicketEncoderImpl.encodeTicket(t);
  
    /*
    
    attempted to take encoded tickets, 
    unmarshal to xml, remarshall to tickets,
    write strings and try to compare. kept throwing exceptions,
    so gate is permanently locked.
    
    //unmarshalling to xml
    JAXBContext jaxbContext = JAXBContext.newInstance("org.solent.com528.project.model.dto");
    Unmarshaller jaxbUnMarshaller = jaxbContext.createUnmarshaller();
    StringReader sr = new StringReader(encodedTicketStr);
    Ticket encodedTicket = (Ticket) jaxbUnMarshaller.unmarshal(sr);   
    StringReader sr2 = new StringReader(encodedTicketStr1);
    Ticket encodedTicket2 = (Ticket) jaxbUnMarshaller.unmarshal(sr2);

    
    //remarshalling
    Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
    //formatting output
    jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
    StringWriter sw1 = new StringWriter();
    StringWriter sw = new StringWriter();
    jaxbMarshaller.marshal(encodedTicket, sw1);
    jaxbMarshaller.marshal(encodedTicket2, sw);
    
    String ticketXml = sw1.toString();
    String ticketXml2 = sw.toString();
    */
    String ticketStr2 = t.toString();
    if("trygate".equals(actionStr)){
        if(ticketStr.equals(ticketStr2)){
            message = "GATE OPEN";
        }
    }
    else {message = "GATE CLOSED";};
  
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        
    </head>
    <body>
        <form action="./gate.jsp" method ="get">
            <input type ="hidden" name="action" value="tryGate">
            
            <input type="hidden" name="desStationName" value="<%=desStationName%>">
            <input type="hidden" name="desZoneStr" value="<%=desZoneStr%>">
            <input type="hidden" name="depStationName" value="<%=depStationName%>">
            <input type="hidden" name="depzoneStr" value="<%=depZoneStr%>">
            <input type="hidden" name="depTimeStr" value="<%=depTimeStr%>">
            <input type="hidden" name="arrTimeStr" value="<%=arrTimeStr%>">
            <input type="hidden" name="validToStr" value="<%=validToStr%>">
            <input type="hidden" name="costStr" value="<%=cost%>">
            <button type="submit">Try Gate</button>
        </form>
        
        <p><%=message%><br><%=actionStr%></p>
        
    </body>
</html>
