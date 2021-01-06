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
    String desStationName = request.getParameter("desStationName");
    String desZoneStr = request.getParameter("desZone");
    String depStationName = request.getParameter("depStationName");
    String depZoneStr = request.getParameter("depZone");
    String actionStr = request.getParameter("action");
    String depTimeStr = request.getParameter("depTime");
    String arrTimeStr = request.getParameter("arrTime");
    
    Ticket t = new Ticket();
    
    Integer depZone = Integer.parseInt(depZoneStr);
    Integer desZone = Integer.parseInt(desZoneStr);
    Integer zonesTrav = 0;
    //determining zones travelled for ticket cost
    if(depZone>desZone){
        zonesTrav = depZone-desZone;
    }
    else if(depZone<desZone){
        zonesTrav = desZone-depZone;
    };
    
    //parse time strings as ints
    //Integer depTimeInt = Integer.parseInt(depTimeStr);
    //Integer arrTimeInt = Integer.parseInt(arrTimeStr);
    //create date objects
    //parsing Long from String
    Long depTimeLong = Long.parseLong(depTimeStr);
    Long arrTimeLong = Long.parseLong(arrTimeStr);
    //new calendar objects
    Calendar calDepTime = Calendar.getInstance();
    Calendar calArrTime = Calendar.getInstance();
    //setting time in M/s as Long
    calDepTime.setTimeInMillis(depTimeLong);
    calArrTime.setTimeInMillis(arrTimeLong);
    
    //instantiating date objects with calendar variables
    Date depTime = calDepTime.getTime();
    Date arrTime = calArrTime.getTime();
    //setting up validToDate to be 12 hours after projected arrival time, to allow the gate to actually open at the end
    Calendar calValidTo = Calendar.getInstance();
    calValidTo = calArrTime;
    calValidTo.add(Calendar.HOUR, 12);
    Date validTo = calValidTo.getTime();
    //making empty ticketMachine
    TicketMachine tm = new TicketMachine();
    //making and populating station
    Station s = stationDAO.findByName(depStationName); 
    //checking for ticketMachines
    //List<TicketMachine> ticketMachineList = new ArrayList<TicketMachine>(); 
    //ticketMachineList = tmdao.findByStationName(depStationName);
    /*if(ticketMachineList.isEmpty()){
    errorMessage = "no ticket machine found for this station!";
    }
    else if(!ticketMachineList.isEmpty()){
        tm = ticketMachineList.get(0);
        String ticketMachineUuid = tm.getUuid();
        configurationPoller.setTicketMachineUuid(ticketMachineUuid);
        configurationPoller.init(0, 10);
        tm.setTicketMachineConfig(serviceFacade.getTicketMachineConfig(ticketMachineUuid));
    }
        message = configurationPoller.getTicketMachineUuid();
        message2 = tm.getUuid();
    */
    
    //setting ticketmachine station as station retrieved by DAO
    tm.setStation(s);
    //setting uuid for config poller
    configurationPoller.setTicketMachineUuid(tm.getUuid());
    //getting config for ticketMachine using service facade method
    tm.setTicketMachineConfig(serviceFacade.getTicketMachineConfig(tm.getUuid()));
    
    //checking if ticketMachine is empty/blank
    if(tm.toString().isBlank() || tm.toString().isEmpty()){
        message = "ticket Machine empty/not found";
        return;
    };
     
        //setting issue date
        t.setIssueDate(depTime);
        //setting start station name
        t.setStartStation(tm.getStation().getName());
        //setting arrival station
        //t.setArrivalStation(desStationName);
        //setting validtodate
        //t.setValidToDate(validTo);
        //retrieving pricingdetails from machine
        PricingDetails pd = tm.getTicketMachineConfig().getPricingDetails();
        //setting price variables
        Double offPeakPrice = pd.getOffpeakPricePerZone();
        Double peakPrice = pd.getPeakPricePerZone();
        //getting priceBandList
        pd.getPriceBandList();
        //setting dummy peak/offpeak times
        Date date = depTime;
        Date peak = new Date();
        peak.setTime(9);
        Date offPeak = new Date();
        offPeak.setTime(11);
        //initialising cost
        Double cost;
        //determining peak/offpeak rate
        if(date.before(peak)){
            cost = zonesTrav * offPeakPrice; 
            t.setCost(cost);
            rateStr = "offPeak";
        }
        if(date.after(peak)){
            cost = zonesTrav * peakPrice;
            t.setCost(cost);
            rateStr = "peak";
        }
        
        
        String encodedTicketStr = TicketEncoderImpl.encodeTicket(t);
        
    //checking if ticketMachine has a config and any details at all
    //message = tm.toString();
    //message2 = tm.getTicketMachineConfig().toString();
    t.getCost();
    //t.getArrivalStation();
    t.getIssueDate();
    t.getStartStation();
    t.getRate();
    Long validToLong = validTo.getTime();
    String validToStr = validToLong.toString();
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>god help me</title>
    </head>
    <body>
        
            <p>You Are Currently At:<%=depStationName%> Station In Zone:<%=depZoneStr%></p>
            <p>You Are Travelling To:<%=desStationName%> Station In Zone:<%=desZoneStr%></p>
            <p>You Are Departing At:<%=depTime%></p>
            <p>You Are Arriving At:<%=arrTime%></p>
            
            <p><%=message%></p>
            <p><%=message2%></p>
            
            <p>You are Travelling Through <%=zonesTrav%> Zones</p>
            <p>You are Travelling at a <%=rateStr%> Time</p>
            <p>Your Ticket will Cost £<%=t.getCost()%></p>
            <p>click below to travel</p>
            <form action = "./gate.jsp" method = "get">
                <input type="hidden" name="encodedTicketStr" value="<%=encodedTicketStr%>">
                <input type="hidden" name="desStationName" value="<%=desStationName%>">
                <input type="hidden" name="desZoneStr" value="<%=desZoneStr%>">
                <input type="hidden" name="depStationName" value="<%=depStationName%>">
                <input type="hidden" name="depZoneStr" value="<%=depZoneStr%>">
                <input type="hidden" name="depTimeStr" value="<%=depTimeStr%>">
                <input type="hidden" name="arrTimeStr" value="<%=arrTimeStr%>">
                <input type="hidden" name="zonesTravStr" value="<%=zonesTrav%>">
                <input type="hidden" name="validToStr" value="<%=validToStr%>">
                <input type="hidden" name="costStr" value="<%=t.getCost()%>">
                <input type="hidden" name="action" value="travel">
                <input type ="hidden" name="ticketStr" value ="<%=t.toString()%>">
                
                <button type="submit">travel to exit gate</button>
            </form>
            
    </body>
</html>
