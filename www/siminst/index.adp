<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<h2>Templates Ready for Mapping</h2>

<p>
  <listtemplate name="avail_templates"></listtemplate>
</p>

<h2>Mapped Templates</h2>

TODO...

<h2>Current Simulations</h2>
<p>
  <include src="/packages/simulation/lib/simulations"/>
</p>

<h2>Help</h2>

<p>
  The process of creating a simulation form a simulation template is referred to as instantiation. The
  instantiation process is divided into two steps:

  <ol>

    <p>
      <li>

        <b>Mapping</b> (Ready Template -> Mapped Template). Starting with
      a ready (complete) simulation template, a copy (clone) is
      created. This new template is then mapped to objects in the
      CityBuild world, such as characters and properties.

      </li>
    </p>

   <p>
     <li>

      <b>Casting</b> (Mapped Template -> Simulation). From a mapped simulation template, a copy (clone) is created,
      and this new template becomes a simulation once it is connected to users in 
      the real world and time frame and other properties of the simulation are specified. 
      A simulation is subdivided into one or more simulation cases
      that each have their own set of users and will execute independently of
      eachother. A large class can thus be divided into smaller groups where each group
      has its own simulation case to play in.

     </li>
   </p>

  </ol>
</p>
