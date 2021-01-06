
<%@page import="java.util.UUID"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">

<!--
<%@page import="java.util.List"%>
 <%@page import="java.util.Calendar"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.Date"%>
<%@page import="org.solent.com528.project.model.service.ServiceFacade"%>
<%@page import="org.solent.com528.project.model.dao.StationDAO"%>
<%@page import="org.solent.com528.project.model.dto.Station"%>
<%@page import="org.solent.com528.project.model.dao.TicketMachineDAO"%>
<%@page import="org.solent.com528.project.model.dto.TicketMachine"%>
-->
<%
    
    String errorMessage = "";
    //accessing request parameters, taken from the previous page
    String desStationName = request.getParameter("desStationName");
    String desZoneStr = request.getParameter("desZone");
    String depStationName = request.getParameter("depStationName");
    String depZoneStr = request.getParameter("depZone");
    String actionStr = request.getParameter("action");
    String depTimeStr = request.getParameter("depTime");
    //parsing strings from requests, to Ints for later use
    Integer desZone = Integer.parseInt(desZoneStr);
    Integer depZone = Integer.parseInt(depZoneStr);
    //getting current date
    Date timeNow = new Date();
    
    //variables for ticket making
    Date depTime = new Date();
    Date arrTime = new Date();
    
    
    //initialising arrayList of dates, for drop down
    List dateList = new ArrayList();
    Date dateArray[] = new Date[24];
    
    //making a calendar object
    Calendar cal = Calendar.getInstance();
    //setting calendar to timeNow
    cal.setTime(timeNow);
    Integer i = 0;
    while(i<24){
        //new date, add an hour to calendar time, date = new time, add to array for a total of 24 slots.
        Date date = new Date();
        cal.add(Calendar.HOUR, 1);
        date = cal.getTime();
        dateArray[i] = date;
        dateList.add(date);
        i++;
    };
    
    //if departure time not selected set to current time
    if (actionStr == null || actionStr.isEmpty()) {
        // do nothing

    }
    
    else if (!"selectDepTime".equals(actionStr)) {
        depTime = timeNow;
        
    } else {
        errorMessage = "ERROR: page called for unknown action";
    }   
    
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Ticket Machine</title>
    </head>
    <body>
        <p>the time currently is:<%=timeNow%></p>
        <p>you are Travelling to:<%=desStationName%> Station, in zone:<%=desZoneStr%></p>
        <p>you are currently at:<%=depStationName%> Station in zone:<%=depZoneStr%></p>
        <h1>Select a Departure Time</h1>
            
        <table border ="1">
            <tr>
                <th>Departure Times</th>    
            </tr>
            <%
                for(int x=0;x<24;x++){
            %>
            <tr>
                <td size="36"><%=dateArray[x].toString()%></td>
                <td>
                    <form action="./arrivalTime.jsp" method="get">
                        <input type="hidden" name ="depTime" value="<%=dateArray[x].getTime()%>">
                        <input type="hidden" name="desStationName" value="<%=desStationName%>">
                        <input type="hidden" name="desZone" value="<%=desZoneStr%>">
                        <input type="hidden" name="depStationName" value="<%=depStationName%>">
                        <input type="hidden" name="depZone" value="<%=depZoneStr%>">
                        <input type="hidden" name="action" value="selectDepTime">
                        <button type="submit">Select Time</button>
                    </form>
                </td>
            </tr>
            <%
                }
            %>
        </table>

       
    </body>
</html>
